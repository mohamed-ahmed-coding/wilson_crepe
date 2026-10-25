import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID")!;
const firebaseClientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL")!;
const firebasePrivateKey = Deno.env.get("FIREBASE_PRIVATE_KEY")!;

// Must match NotificationsService in Flutter.
const ANDROID_CHANNEL_ID = "order_notifications";

const supabase = createClient(
  supabaseUrl,
  supabaseServiceRoleKey,
);

type SupportedLanguage = "ar" | "en";

function normalizeLanguage(raw: unknown): SupportedLanguage {
  const language = String(raw ?? "ar").trim().toLowerCase();

  return language.startsWith("ar") ? "ar" : "en";
}

function normalizeStatus(raw: unknown): string {
  const status = String(raw ?? "")
    .trim()
    .toLowerCase()
    .replace(/[\s_-]/g, "");

  switch (status) {
    case "pending":
      return "pending";

    case "preparing":
      return "preparing";

    case "outfordelivery":
      return "out_for_delivery";

    case "canceled":
    case "cancelled":
      return "canceled";

    default:
      return String(raw ?? "");
  }
}

async function getUserLanguage(
  userId: string,
): Promise<SupportedLanguage> {
  const { data, error } = await supabase
    .from("users")
    .select("language")
    .eq("id", userId)
    .maybeSingle();

  if (error) {
    console.error("Failed to get user language:", error.message);
    return "ar";
  }

  return normalizeLanguage(data?.language);
}

async function getFirebaseAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  const privateKey = await importPKCS8(
    firebasePrivateKey.replace(/\\n/g, "\n"),
    "RS256",
  );

  const jwt = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(firebaseClientEmail)
    .setSubject(firebaseClientEmail)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(privateKey);

  const response = await fetch(
    "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: jwt,
      }),
    },
  );

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to get Firebase access token: ${error}`);
  }

  const data = await response.json();
  return data.access_token;
}

function getNotificationContent(
  status: string,
  orderId: number,
  language: SupportedLanguage,
) {
  if (language === "ar") {
    switch (status) {
      case "pending":
        return {
          title: "تم استلام طلبك",
          body: `تم استلام طلبك رقم ${orderId} بنجاح.`,
        };

      case "preparing":
        return {
          title: "جاري تحضير طلبك",
          body: `جاري الآن تحضير طلبك رقم ${orderId}.`,
        };

      case "out_for_delivery":
        return {
          title: "طلبك في الطريق إليك",
          body: `طلبك رقم ${orderId} في الطريق إليك الآن!`,
        };

      case "canceled":
        return {
          title: "تم إلغاء الطلب",
          body: `تم إلغاء طلبك رقم ${orderId}.`,
        };

      default:
        return {
          title: "تحديث الطلب",
          body: `تم تحديث حالة طلبك رقم ${orderId}.`,
        };
    }
  }

  switch (status) {
    case "pending":
      return {
        title: "Order Received",
        body: `Your order #${orderId} has been received.`,
      };

    case "preparing":
      return {
        title: "Order Preparing",
        body: `Your order #${orderId} is now being prepared.`,
      };

    case "out_for_delivery":
      return {
        title: "Order On The Way",
        body: `Your order #${orderId} is on the way!`,
      };

    case "canceled":
      return {
        title: "Order Canceled",
        body: `Your order #${orderId} has been canceled.`,
      };

    default:
      return {
        title: "Order Update",
        body: `Your order #${orderId} status has been updated.`,
      };
  }
}

async function sendNotification(
  accessToken: string,
  token: string,
  orderId: number,
  status: string,
  language: SupportedLanguage,
): Promise<boolean> {
  const notification = getNotificationContent(
    status,
    orderId,
    language,
  );

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: {
            type: "order_status",
            order_id: String(orderId),
            status,
            language,
          },
          android: {
            priority: "HIGH",
            notification: {
              sound: "default",
              channel_id: ANDROID_CHANNEL_ID,
            },
          },
        },
      }),
    },
  );

  if (!response.ok) {
    const error = await response.text();
    console.error(`FCM failed: ${error}`);
    return false;
  }

  return true;
}

Deno.serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return Response.json(
        { success: false, error: "Method not allowed" },
        { status: 405 },
      );
    }

    const body = await req.json();

    const record = body.record;
    const oldRecord = body.old_record;

    if (!record) {
      return Response.json(
        {
          success: false,
          error: "Webhook record is missing",
        },
        { status: 400 },
      );
    }

    const orderId = Number(record.id);
    const userId = record.user_id;
    const status = normalizeStatus(record.status);
    const oldStatus = oldRecord
      ? normalizeStatus(oldRecord.status)
      : undefined;

    if (!Number.isFinite(orderId) || orderId <= 0 || !userId || !status) {
      return Response.json(
        {
          success: false,
          error: "Order id, user id and status are required",
        },
        { status: 400 },
      );
    }

    // Do not notify if the status did not change.
    if (oldStatus === status) {
      return Response.json({
        success: true,
        message: "Status did not change",
      });
    }

    console.log(`Order #${orderId}: ${oldStatus} -> ${status}`);

    const { data: devices, error } = await supabase
      .from("user_devices")
      .select("id, fcm_token")
      .eq("user_id", userId);

    if (error) {
      throw new Error(
        `Failed to get user devices: ${error.message}`,
      );
    }

    if (!devices || devices.length === 0) {
      return Response.json({
        success: true,
        message: "No devices found for this user",
      });
    }

    // Use the customer's saved language.
    const language = await getUserLanguage(userId);
    const accessToken = await getFirebaseAccessToken();

    let sentCount = 0;

    for (const device of devices) {
      const sent = await sendNotification(
        accessToken,
        device.fcm_token,
        orderId,
        status,
        language,
      );

      if (sent) {
        sentCount++;
      }
    }

    return Response.json({
      success: true,
      order_id: orderId,
      status,
      language,
      devices: devices.length,
      sent: sentCount,
    });
  } catch (error) {
    console.error(error);

    return Response.json(
      {
        success: false,
        error: error instanceof Error
          ? error.message
          : String(error),
      },
      { status: 500 },
    );
  }
});