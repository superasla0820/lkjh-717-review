/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
        },
        study: {
          chinese: '#ef4444', // 國文 - 暖紅
          english: '#3b82f6', // 英文 - 活力藍
          math: '#10b981',    // 數學 - 翡翠綠
          science: '#8b5cf6', // 自然 - 探索紫
          social: '#f59e0b',  // 社會 - 大地橘
        }
      }
    },
  },
  plugins: [],
}
