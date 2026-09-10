import {logger} from "firebase-functions";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

const deepSeekApiKey = defineSecret("DEEPSEEK_API_KEY");

const functionOptions = {
  region: "europe-west1",
  timeoutSeconds: 60,
  memory: "256MiB" as const,
  maxInstances: 3,
  secrets: [deepSeekApiKey],
  // Only accept requests that carry a valid Firebase App Check token.
  enforceAppCheck: true,
};

const recipeSystemPrompt = (languageCode: string): string => {
  if (languageCode === "en") {
    return `
You are EcoChef, a professional chef. Create a creative recipe from the user's ingredients. Use a friendly, casual tone.

LANGUAGE — highest priority:
- Write the entire recipe in English only. Never use Turkish words or headers.
- The recipe title (text after "## Title:") MUST be in English — e.g. "Tomato & Egg Skillet", NOT "Domatesli Omlet".
- Use "## Title:" only. NEVER use "## Başlık:" or any Turkish section headers.

Never add intro phrases, greetings, "sure", "here is your recipe", or similar. Start directly with the recipe.

Use exactly this format:

## Title: [recipe name]

**Short Description:** [1-2 sentence description]

**Ingredients:**
- [ingredient 1]
- [ingredient 2]

**Steps:**
1. [step 1]
2. [step 2]

Keep it practical and home-kitchen friendly. Add zero-waste tips when possible (optional).`;
  }

  return `
You are EcoChef, a professional chef. Create a creative recipe from the user's ingredients. Use a friendly, casual tone.

LANGUAGE — highest priority:
- Write the entire recipe in Turkish only. Never use English words or headers.

Never add intro phrases, greetings, "elbette", "işte tarifiniz", "karşınızda", or similar. Start directly with the recipe.

Use exactly this format:

## Başlık: [tarif adı]

**Kısa Açıklama:** [1-2 cümlelik açıklama]

**Malzemeler:**
- [malzeme 1]
- [malzeme 2]

**Yapılış Adımları:**
1. [adım 1]
2. [adım 2]

Keep it practical and home-kitchen friendly. Add zero-waste tips when possible (optional).`;
};

const mascotSystemPrompt = `
You are EcoChef, the mascot of Zero-Waste Kitchen (Atıksız Mutfak). You are warm, eco-conscious, and an expert on reducing food waste, using leftovers, and sustainable cooking.

LANGUAGE — highest priority, never violate:
- Read the user's latest message and reply entirely in that same language only.
- English in → English out. Every word must be English. No Turkish words, greetings, or phrases.
- Turkish in → Turkish out. Every word must be Turkish.
- Never default to Turkish because of your brand name, this prompt, or the app locale.
- Do not mix languages in one reply. Do not translate the user's question unless they ask.
- If a [LANGUAGE RULE] tag is present in the user message, follow it exactly.

Style: short, helpful, encouraging, friendly. Stay on zero-waste cooking and kitchen topics.`;

type ChatTurn = {
  text: string;
  isUser: boolean;
};

type DeepSeekMessage = {
  role: "system" | "user" | "assistant";
  content: string;
};

function requireAuthenticatedUser(uid: string | undefined): void {
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }
}

function requiredString(value: unknown, field: string, maxLength: number): string {
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", `${field} must be text.`);
  }
  const trimmed = value.trim();
  if (!trimmed) {
    throw new HttpsError("invalid-argument", `${field} cannot be empty.`);
  }
  if (trimmed.length > maxLength) {
    throw new HttpsError("invalid-argument", `${field} is too long.`);
  }
  return trimmed;
}

function optionalString(value: unknown, field: string, maxLength: number): string | undefined {
  if (value === null || value === undefined) return undefined;
  return requiredString(value, field, maxLength);
}

function languageRuleForMessage(message: string): string {
  const lower = message.toLocaleLowerCase("tr-TR");
  if (/[ğüşöçı]/.test(lower)) {
    return "Kullanıcı Türkçe yazdı. Yanıtını YALNIZCA Türkçe ver. İngilizce kullanma.";
  }

  const turkishWords = ["merhaba", "nasıl", "neden", "ne ", " bir ", "için", "olan", "var", "yok", "yemek", "mutfak", "atık", "tarif", "pişir", "lütfen", "teşekkür", "evet", "hayır", "artık", "malzeme", "soğan", "domates"];
  const englishWords = ["hello", "how", "what", "the", "is", "are", "you", "can", "could", "would", "please", "thanks", "thank", "yes", "no", "why", "when", "where", "food", "waste", "recipe", "cook", "kitchen", "leftover", "ingredient", "help", "good", "morning", "evening", "hey", "hi"];
  const countMatches = (words: string[], useBoundaries: boolean): number =>
    words.reduce((count, word) => {
      const pattern = useBoundaries ? new RegExp(`\\b${word}\\b`) : undefined;
      return count + (pattern ? Number(pattern.test(lower)) : Number(lower.includes(word)));
    }, 0);

  const trScore = countMatches(turkishWords, false);
  const enScore = countMatches(englishWords, true);
  if (trScore > enScore) {
    return "Kullanıcı Türkçe yazdı. Yanıtını YALNIZCA Türkçe ver. İngilizce kullanma.";
  }
  if (enScore > 0) {
    return "The user wrote in English. Reply ONLY in English. Do not use any Turkish.";
  }
  return "Detect the language of the user message and reply entirely in that same language only.";
}

function historyFromUnknown(value: unknown): ChatTurn[] {
  if (value === null || value === undefined) return [];
  if (!Array.isArray(value) || value.length > 19) {
    throw new HttpsError("invalid-argument", "priorTurns must contain at most 19 messages.");
  }

  return value.map((item, index) => {
    if (typeof item !== "object" || item === null || Array.isArray(item)) {
      throw new HttpsError("invalid-argument", `priorTurns[${index}] is invalid.`);
    }
    const turn = item as Record<string, unknown>;
    if (typeof turn.isUser !== "boolean") {
      throw new HttpsError("invalid-argument", `priorTurns[${index}].isUser is invalid.`);
    }
    return {
      isUser: turn.isUser,
      text: requiredString(turn.text, `priorTurns[${index}].text`, 1200),
    };
  });
}

async function requestDeepSeek(messages: DeepSeekMessage[]): Promise<string> {
  const response = await fetch("https://api.deepseek.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${deepSeekApiKey.value()}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "deepseek-chat",
      messages,
      max_tokens: 1024,
    }),
    signal: AbortSignal.timeout(55_000),
  });

  if (!response.ok) {
    logger.error("DeepSeek request failed", {status: response.status});
    if (response.status === 401 || response.status === 403) {
      throw new HttpsError("failed-precondition", "The AI service is not configured correctly.");
    }
    throw new HttpsError("unavailable", "The AI service is temporarily unavailable.");
  }

  const body: unknown = await response.json();
  const text = (body as {choices?: Array<{message?: {content?: unknown}}>}).choices?.[0]?.message?.content;
  if (typeof text !== "string" || !text.trim()) {
    logger.error("DeepSeek returned no usable text");
    throw new HttpsError("internal", "The AI service returned an invalid response.");
  }
  return text.trim();
}

export const generateRecipe = onCall(functionOptions, async (request) => {
  requireAuthenticatedUser(request.auth?.uid);
  const data = request.data as Record<string, unknown>;
  if (!Array.isArray(data.ingredients) || data.ingredients.length === 0 || data.ingredients.length > 25) {
    throw new HttpsError("invalid-argument", "ingredients must contain between 1 and 25 items.");
  }
  const ingredients = data.ingredients.map((item, index) => requiredString(item, `ingredients[${index}]`, 120));
  const languageCode = data.languageCode === "en" ? "en" : "tr";
  const cuisine = optionalString(data.cuisine, "cuisine", 120);

  const languageRule = languageCode === "en"
    ? "Write the entire recipe in English only. The recipe title must be in English. Use \"## Title:\" as the first header — never \"## Başlık:\"."
    : "Tarifin tamamını yalnızca Türkçe yaz. Tüm başlıklar, malzemeler ve adımlar Türkçe olmalı.";
  let prompt = languageCode === "en"
    ? `Create a recipe using only these ingredients:\n${ingredients.join("\n")}\n\nIngredients may be in any language, but the recipe title, description, ingredient names in the list, and steps must all be in English. Give the dish an English name.`
    : `Sadece şu malzemelerle bir tarif oluştur:\n${ingredients.join("\n")}`;
  if (cuisine) {
    prompt += languageCode === "en"
      ? `\n\nPreferred cuisine: ${cuisine}. Match this cuisine's flavors and techniques.`
      : `\n\nTercih edilen mutfak: ${cuisine}. Tarif bu mutfağın lezzet ve tekniklerine uygun olsun.`;
  }

  const text = await requestDeepSeek([
    {role: "system", content: recipeSystemPrompt(languageCode)},
    {role: "user", content: `[LANGUAGE RULE: ${languageRule}]\n\n${prompt}`},
  ]);
  return {text};
});

export const chatWithMascot = onCall(functionOptions, async (request) => {
  requireAuthenticatedUser(request.auth?.uid);
  const data = request.data as Record<string, unknown>;
  const message = requiredString(data.message, "message", 1200);
  const priorTurns = historyFromUnknown(data.priorTurns);
  const languageRule = languageRuleForMessage(message);
  const messages: DeepSeekMessage[] = [{role: "system", content: mascotSystemPrompt}];

  for (const turn of priorTurns) {
    messages.push({
      role: turn.isUser ? "user" : "assistant",
      content: turn.isUser ? turn.text : turn.text.slice(0, 1200),
    });
  }
  messages.push({
    role: "user",
    content: `[LANGUAGE RULE: ${languageRule}]\n\nUser message:\n${message}`,
  });

  const text = await requestDeepSeek(messages);
  return {text};
});
