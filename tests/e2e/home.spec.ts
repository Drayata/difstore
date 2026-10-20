import { expect, test } from "@playwright/test";

test("home mobile tidak overflow dan CTA menuju katalog", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
  await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth <= document.documentElement.clientWidth)).toBe(true);
  await page.getByRole("link", { name: "Jelajahi Produk" }).click();
  await expect(page.getByRole("heading", { name: "Produk digital" })).toBeVisible();
});
