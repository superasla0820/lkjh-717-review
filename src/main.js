import { createApp } from 'vue';
import App from './App.vue';
import './style.css';

/**
 * 防禦性應用程式初始化函數
 * 遵循系統規範：避免 DOMContentLoaded 於異步模組載入後已觸發所導致的掛載鎖死
 */
function initApp() {
  const mountElement = document.getElementById('app');
  if (!mountElement) {
    console.error('找不到掛載節點 #app，延後重試');
    return;
  }
  
  const app = createApp(App);
  app.mount('#app');
}

// 檢測當前 DOM 狀態，確保 100% 正常掛載
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initApp);
} else {
  initApp();
}
