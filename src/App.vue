<template>
  <div class="min-h-screen bg-slate-100 text-slate-800 pb-16">
    <!-- 頂部勇者狀態導航列 -->
    <header class="bg-gradient-to-r from-indigo-900 via-indigo-800 to-purple-900 text-white sticky top-0 z-30 shadow-lg border-b border-indigo-700/50">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 py-3">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
          <!-- 左側：學校班級與學生身分 -->
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-2xl bg-white/10 backdrop-blur-sm border border-white/20 flex items-center justify-center text-3xl shadow-inner">
              {{ currentPet.emoji }}
            </div>
            <div>
              <div class="flex items-center gap-2 flex-wrap">
                <span class="px-2 py-0.5 text-[11px] font-bold bg-amber-400 text-slate-950 rounded-full shadow-xs">
                  林口國中 717 班
                </span>
                <h1 class="text-base sm:text-lg font-extrabold tracking-tight text-white">
                  每日課後複習・勇者學園
                </h1>
              </div>
              <div class="flex items-center gap-2 text-xs text-indigo-200 mt-0.5">
                <span>座號：<strong class="text-white">{{ profile.seatNo }}號</strong></span>
                <span>｜</span>
                <span>姓名：<strong class="text-white">{{ profile.studentName }}</strong></span>
                <button 
                  @click="showProfileModal = true" 
                  class="text-[11px] underline text-amber-300 hover:text-amber-200 ml-1"
                >
                  編輯資料
                </button>
              </div>
            </div>
          </div>

          <!-- 右側：RPG 等級、經驗條、金幣與連勝 -->
          <div class="flex items-center gap-3 sm:gap-4 flex-wrap bg-slate-900/40 px-3.5 py-2 rounded-xl border border-white/10">
            <div class="flex items-center gap-2">
              <span class="px-2 py-0.5 bg-indigo-500 text-white font-black text-xs rounded-md">
                Lv.{{ heroLevel }}
              </span>
              <div class="w-24 sm:w-28">
                <div class="flex justify-between text-[10px] text-indigo-200 font-semibold mb-0.5">
                  <span>{{ currentPet.title }}</span>
                  <span>{{ profile.exp % 100 }}/100 EXP</span>
                </div>
                <div class="w-full h-2 bg-slate-700 rounded-full overflow-hidden">
                  <div 
                    class="h-full bg-gradient-to-r from-amber-400 to-yellow-300 transition-all duration-500"
                    :style="{ width: `${profile.exp % 100}%` }"
                  ></div>
                </div>
              </div>
            </div>

            <div class="h-6 w-px bg-white/15 hidden sm:block"></div>

            <div class="flex items-center gap-3 text-xs font-bold">
              <span class="flex items-center gap-1 text-amber-300" title="勇者金幣">
                💰 {{ profile.coins }}
              </span>
              <span class="flex items-center gap-1 text-pink-300" title="寶箱扭蛋券">
                🎟️ {{ profile.gachaTickets }}張
              </span>
              <span class="flex items-center gap-1 text-orange-300" title="完成全科複習天數">
                🔥 {{ totalClearDays }}天全制霸
              </span>
            </div>
          </div>
        </div>

        <!-- 導覽分頁切換列 -->
        <nav class="flex items-center gap-1.5 sm:gap-2 mt-3 pt-2 border-t border-white/10 overflow-x-auto no-scrollbar">
          <button
            v-for="tab in navTabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            class="px-3.5 py-1.5 rounded-lg text-xs sm:text-sm font-bold transition-all whitespace-nowrap flex items-center gap-1.5"
            :class="activeTab === tab.id 
              ? 'bg-white text-indigo-950 shadow-sm scale-[1.02]' 
              : 'text-indigo-100 hover:bg-white/10'"
          >
            <span>{{ tab.icon }}</span>
            <span>{{ tab.label }}</span>
            <span 
              v-if="tab.badge" 
              class="px-1.5 py-0.2 text-[10px] rounded-full bg-rose-500 text-white"
            >
              {{ tab.badge }}
            </span>
          </button>
        </nav>
      </div>
    </header>

    <!-- 主內容區 -->
    <main class="max-w-6xl mx-auto px-4 sm:px-6 py-6 space-y-6">

      <!-- ==================================================== -->
      <!-- 分頁 1：⚔️ 今日複習闖關 (CheckList + 打怪小遊戲) -->
      <!-- ==================================================== -->
      <div v-if="activeTab === 'daily'" class="space-y-6">
        <!-- 日期切換與今日課表橫幅 -->
        <div class="bg-white rounded-2xl p-4 sm:p-5 border border-slate-200 shadow-xs flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-xl bg-indigo-50 border border-indigo-100 flex flex-col items-center justify-center text-indigo-700 shrink-0">
              <span class="text-[10px] font-bold uppercase">{{ selectedDayInfo.month }}月</span>
              <span class="text-lg font-black leading-none">{{ selectedDayInfo.day }}</span>
            </div>
            <div>
              <div class="flex items-center gap-2">
                <h2 class="text-lg font-extrabold text-slate-900">
                  {{ selectedDateKey }}（{{ selectedDayInfo.dayName }}）
                </h2>
                <span class="px-2.5 py-0.5 text-xs font-bold rounded-full bg-indigo-100 text-indigo-700">
                  {{ selectedDayInfo.tag }}
                </span>
                <span 
                  v-if="isSelectedDayParentVerified" 
                  class="px-2.5 py-0.5 text-xs font-bold rounded-full bg-amber-100 text-amber-800 border border-amber-300 flex items-center gap-1"
                >
                  🏅 家長已簽核
                </span>
              </div>
              <p class="text-xs text-slate-500 mt-0.5">
                依據 717 班課表，今日回家必複習主科共 <strong class="text-indigo-600">{{ currentDayTasks.length }}</strong> 科。完成複習即可討伐怠惰魔王！
              </p>
            </div>
          </div>

          <!-- 快速切換日期 -->
          <div class="flex items-center gap-2 self-end sm:self-center">
            <button 
              @click="shiftSelectedDate(-1)"
              class="px-3 py-1.5 text-xs font-bold bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg transition"
            >
              ◀ 前一天
            </button>
            <button 
              @click="resetToToday"
              class="px-3 py-1.5 text-xs font-bold bg-indigo-50 hover:bg-indigo-100 text-indigo-700 rounded-lg transition"
            >
              回到今天 (10/22)
            </button>
            <button 
              @click="shiftSelectedDate(1)"
              class="px-3 py-1.5 text-xs font-bold bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg transition"
            >
              後一天 ▶
            </button>
          </div>
        </div>

        <!-- 上半部：左邊「怠惰魔王討伐戰 & 守護神獸」+ 右邊「勇者專注計時番茄鐘」 -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <!-- 魔王討伐戰舞台 -->
          <div class="lg:col-span-2 bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 text-white rounded-2xl p-6 shadow-md relative overflow-hidden border border-indigo-800/60">
            <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-6">
              <!-- 左：我方守護神獸 -->
              <div class="flex items-center gap-4">
                <div class="w-20 h-20 rounded-2xl bg-indigo-500/20 border-2 border-indigo-400/40 flex items-center justify-center text-5xl shadow-lg animate-bounce">
                  {{ currentPet.emoji }}
                </div>
                <div>
                  <span class="text-[11px] font-bold uppercase tracking-wider text-indigo-300">717 守護神獸</span>
                  <h3 class="text-xl font-black text-white mt-0.5">{{ currentPet.name }}</h3>
                  <p class="text-xs text-indigo-200 mt-1 max-w-xs">{{ currentPet.desc }}</p>
                </div>
              </div>

              <!-- VS 標誌 -->
              <div class="hidden sm:flex flex-col items-center justify-center">
                <span class="text-2xl font-black italic text-amber-400">VS</span>
              </div>

              <!-- 右：今日怠惰魔王狀態 -->
              <div class="bg-slate-800/80 border border-slate-700 rounded-xl p-4 min-w-[230px]">
                <div class="flex items-center justify-between mb-1.5">
                  <span class="text-xs font-bold text-rose-300 flex items-center gap-1">
                    <span>👾</span> 今日怠惰魔王
                  </span>
                  <span class="text-xs font-extrabold" :class="bossHpPercent === 0 ? 'text-emerald-400' : 'text-rose-400'">
                    HP {{ bossHpPercent }}%
                  </span>
                </div>
                <!-- 魔王血量條 -->
                <div class="w-full h-3.5 bg-slate-950 rounded-full overflow-hidden p-0.5 border border-slate-700">
                  <div 
                    class="h-full rounded-full transition-all duration-500"
                    :class="bossHpPercent === 0 ? 'bg-emerald-500' : 'bg-gradient-to-r from-rose-600 to-orange-500'"
                    :style="{ width: `${bossHpPercent}%` }"
                  ></div>
                </div>
                <p class="text-[11px] text-slate-300 mt-2">
                  <template v-if="bossHpPercent === 0">
                    🎉 <strong>魔王已被徹底擊敗！</strong> 今日主科複習 100% ALL CLEAR！快找家長簽章領取大禮包！
                  </template>
                  <template v-else>
                    尚有 <strong>{{ remainingTaskCount }}</strong> 科未複習！每完成一科或通過「⚡快問快答」即可重創魔王！
                  </template>
                </p>
              </div>
            </div>
          </div>

          <!-- 勇者專注修煉計時器 (番茄鐘) -->
          <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-xs flex flex-col justify-between">
            <div>
              <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-indigo-600 bg-indigo-50 px-2.5 py-1 rounded-md">
                  ⏱️ 勇者專注修煉鐘
                </span>
                <span class="text-xs text-slate-400">遠離手機・高效複習</span>
              </div>
              <div class="my-4 text-center">
                <div class="text-4xl font-black tracking-wider text-slate-900 font-mono">
                  {{ formattedTimer }}
                </div>
                <p class="text-xs text-slate-500 mt-1">
                  {{ timerRunning ? '🔥 專注修煉進行中...請專心看書！' : '選擇專注時間，完成可獲 +20 金幣！' }}
                </p>
              </div>
            </div>
            <div class="space-y-2">
              <div class="grid grid-cols-3 gap-1.5">
                <button 
                  @click="setTimerMinutes(15)" 
                  class="py-1 text-xs font-semibold rounded border border-slate-200 hover:bg-slate-50"
                  :disabled="timerRunning"
                >15分鐘</button>
                <button 
                  @click="setTimerMinutes(25)" 
                  class="py-1 text-xs font-semibold rounded border border-slate-200 hover:bg-slate-50"
                  :disabled="timerRunning"
                >25分鐘</button>
                <button 
                  @click="setTimerMinutes(1)" 
                  class="py-1 text-xs font-semibold rounded border border-slate-200 hover:bg-slate-50"
                  :disabled="timerRunning"
                >1分鐘(測試)</button>
              </div>
              <div class="flex gap-2">
                <button 
                  @click="toggleTimer"
                  class="flex-1 py-2 rounded-xl text-xs font-bold text-white shadow-xs transition"
                  :class="timerRunning ? 'bg-amber-500 hover:bg-amber-600' : 'bg-indigo-600 hover:bg-indigo-700'"
                >
                  {{ timerRunning ? '⏸ 暫停修煉' : '▶ 開始專注複習' }}
                </button>
                <button 
                  @click="resetTimer"
                  class="px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 hover:bg-slate-200 text-slate-600"
                >
                  重置
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- 下半部：今日必複習主科 CheckList 卡片清單 -->
        <div class="bg-white rounded-2xl p-5 sm:p-6 border border-slate-200 shadow-xs space-y-5">
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-100">
            <div>
              <h3 class="text-lg font-extrabold text-slate-900 flex items-center gap-2">
                <span>📋</span> {{ selectedDateKey }}（{{ selectedDayInfo.dayName }}）課後複習 Check List
              </h3>
              <p class="text-xs text-slate-500 mt-0.5">
                請依今日課表完成各科複習，填寫「複習範圍/備註」，並點擊「⚡ 快問快答驗收」發動暴擊！
              </p>
            </div>
            <div class="flex items-center gap-2">
              <button 
                @click="activeTab = 'parent'"
                class="px-3.5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs flex items-center gap-1.5 transition"
              >
                <span>📲</span> 產生家長/老師回報卡
              </button>
            </div>
          </div>

          <!-- 各科目卡片 -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div 
              v-for="task in currentDayTasks"
              :key="task.subject"
              class="rounded-2xl border-2 p-4 transition-all flex flex-col justify-between gap-4"
              :class="task.done 
                ? 'bg-emerald-50/40 border-emerald-300 shadow-xs' 
                : 'bg-white border-slate-200 hover:border-indigo-300'"
            >
              <div class="space-y-3">
                <!-- 科目頂部列 -->
                <div class="flex items-start justify-between gap-2">
                  <div class="flex items-center gap-2.5">
                    <span class="text-2xl">{{ getSubjectMeta(task.subject).icon }}</span>
                    <div>
                      <div class="flex items-center gap-2">
                        <h4 class="text-base font-extrabold text-slate-900">{{ task.subject }}</h4>
                        <span 
                          v-if="task.quizPassed" 
                          class="px-2 py-0.5 text-[10px] font-extrabold bg-amber-400 text-slate-950 rounded-full"
                        >
                          ⚡ 暴擊驗收通過
                        </span>
                      </div>
                      <p class="text-xs text-slate-500 mt-0.5">
                        守關怪物：{{ getSubjectMeta(task.subject).monsterEmoji }} {{ getSubjectMeta(task.subject).monsterName }}
                      </p>
                    </div>
                  </div>

                  <!-- 完成狀態標籤 -->
                  <span 
                    class="px-2.5 py-1 rounded-full text-xs font-bold"
                    :class="task.done ? 'bg-emerald-600 text-white' : 'bg-slate-100 text-slate-600'"
                  >
                    {{ task.done ? '✔ 已完成複習' : '☐ 待複習' }}
                  </span>
                </div>

                <!-- 複習指引提示 -->
                <div class="text-xs bg-slate-50 p-2.5 rounded-xl border border-slate-200/80 text-slate-600">
                  💡 <strong>複習重點建議：</strong>{{ getSubjectMeta(task.subject).guide }}
                </div>

                <!-- 學生填寫今日複習內容備註（讓老師與家長知道具體讀了什麼） -->
                <div>
                  <label class="block text-[11px] font-bold text-slate-600 mb-1">
                    ✏️ 今日複習進度 / 頁碼備註（老師與家長檢視用）：
                  </label>
                  <input 
                    type="text"
                    v-model="task.note"
                    @change="saveNote(selectedDateKey, task.subject, task.note)"
                    :placeholder="`例如：複習${task.subject}課本 L2、完成習作訂正...`"
                    class="w-full text-xs px-3 py-2 rounded-lg border border-slate-300 bg-white focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                  />
                </div>
              </div>

              <!-- 底部操作按鈕：一般打勾 vs 快問快答小遊戲驗收 -->
              <div class="pt-3 border-t border-slate-200/60 flex items-center gap-2">
                <button 
                  @click="toggleSubjectDone(selectedDateKey, task.subject)"
                  class="flex-1 py-2 px-3 rounded-xl text-xs font-bold transition flex items-center justify-center gap-1.5"
                  :class="task.done 
                    ? 'bg-slate-200 hover:bg-slate-300 text-slate-700' 
                    : 'bg-indigo-600 hover:bg-indigo-700 text-white shadow-xs'"
                >
                  <span>{{ task.done ? '↩ 取消打勾' : '✔ 完成打卡 (+25 EXP)' }}</span>
                </button>

                <button 
                  @click="openQuizModal(task.subject)"
                  class="py-2 px-3.5 rounded-xl text-xs font-extrabold transition flex items-center justify-center gap-1 shadow-xs"
                  :class="task.quizPassed 
                    ? 'bg-amber-100 text-amber-900 border border-amber-300 hover:bg-amber-200' 
                    : 'bg-gradient-to-r from-amber-400 to-orange-400 hover:from-amber-500 hover:to-orange-500 text-slate-950'"
                >
                  <span>⚡</span>
                  <span>{{ task.quizPassed ? '再次挑戰題庫' : '快問快答驗收 (雙倍獎勵!)' }}</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ==================================================== -->
      <!-- 分頁 2：📅 1~12月 全年度 CheckList 月曆表 -->
      <!-- ==================================================== -->
      <div v-if="activeTab === 'calendar'" class="space-y-6">
        <div class="bg-white rounded-2xl p-5 sm:p-6 border border-slate-200 shadow-xs space-y-5">
          <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4 pb-4 border-b border-slate-100">
            <div>
              <h2 class="text-lg font-extrabold text-slate-900">
                📅 林口國中 七年十七班 — 每日課後複習 Check List（1~12月全年度日曆版）
              </h2>
              <p class="text-xs text-slate-500 mt-0.5">
                支援全年度 1 至 12 月份切換！點擊任一日期格子即可切換至該日進行打卡或查看紀錄。
              </p>
            </div>
            <div class="flex flex-wrap items-center gap-2">
              <!-- 年份選擇 -->
              <select 
                v-model.number="calendarYear"
                class="px-3 py-2 rounded-xl text-xs font-extrabold bg-slate-100 text-slate-800 border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option :value="2026">2026 年 (115學年上)</option>
                <option :value="2027">2027 年 (115學年下)</option>
              </select>

              <button 
                @click="exportExcelCsv('month')"
                class="px-3.5 py-2 rounded-xl text-xs font-bold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs flex items-center gap-1"
              >
                📥 匯出 {{ calendarMonth }} 月 Excel (CSV)
              </button>
              <button 
                @click="exportExcelCsv('year')"
                class="px-3.5 py-2 rounded-xl text-xs font-bold bg-indigo-600 hover:bg-indigo-700 text-white shadow-xs flex items-center gap-1"
              >
                📊 匯出全年 1~12 月總表
              </button>
            </div>
          </div>

          <!-- 1 ~ 12 月份快速切換導覽列 -->
          <div class="grid grid-cols-4 sm:grid-cols-6 lg:grid-cols-12 gap-2">
            <button
              v-for="m in 12"
              :key="m"
              @click="calendarMonth = m"
              class="py-2 px-2 rounded-xl text-xs font-extrabold transition flex flex-col items-center justify-center border"
              :class="calendarMonth === m 
                ? 'bg-indigo-600 text-white border-indigo-600 shadow-sm scale-[1.03]' 
                : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-indigo-50/50 hover:border-indigo-300'"
            >
              <span>{{ m }}月</span>
              <span 
                class="text-[10px] mt-0.5 px-1.5 rounded-full"
                :class="calendarMonth === m ? 'bg-indigo-800 text-indigo-100' : 'text-slate-400'"
              >
                ★{{ getMonthClearCount(calendarYear, m) }}天
              </span>
            </button>
          </div>

          <!-- 星期表頭 -->
          <div class="grid grid-cols-7 gap-2 text-center text-xs font-extrabold text-slate-600 bg-slate-100 py-2.5 rounded-xl">
            <div class="text-rose-600">週日</div>
            <div>週一</div>
            <div>週二</div>
            <div>週三</div>
            <div>週四</div>
            <div>週五</div>
            <div class="text-indigo-600">週六</div>
          </div>

          <!-- 月曆格子 -->
          <div class="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-7 gap-2.5">
            <!-- 前導空白格 (僅在 md 以上 7 欄顯示對齊星期) -->
            <div 
              v-for="empty in calendarLeadingEmptyCount" 
              :key="`empty-${empty}`"
              class="hidden md:block bg-slate-50/50 rounded-xl border border-dashed border-slate-200 min-h-[130px]"
            ></div>

            <!-- 每一天 -->
            <div 
              v-for="dayItem in currentMonthSchedule"
              :key="dayItem.dateKey"
              @click="selectDateFromCalendar(dayItem.dateKey)"
              class="rounded-xl border p-2.5 min-h-[135px] flex flex-col justify-between cursor-pointer transition hover:shadow-md"
              :class="[
                dayItem.dateKey === selectedDateKey ? 'ring-2 ring-indigo-600 border-indigo-500 bg-indigo-50/20' : 'border-slate-200 bg-white',
                isDayAllClear(dayItem.dateKey, dayItem.subjects) ? 'bg-emerald-50/40 border-emerald-300' : ''
              ]"
            >
              <div>
                <!-- 日期與全制霸徽章 -->
                <div class="flex items-center justify-between mb-2">
                  <span 
                    class="text-xs font-black px-1.5 py-0.5 rounded"
                    :class="dayItem.dateKey === '2026-10-22' ? 'bg-indigo-600 text-white' : 'text-slate-700'"
                  >
                    {{ dayItem.displayDate }}
                    <span class="md:hidden text-[10px] font-normal">({{ dayItem.dayName.replace('星期', '週') }})</span>
                  </span>

                  <div class="flex items-center gap-1">
                    <span v-if="isDayParentVerified(dayItem.dateKey)" title="家長已簽章" class="text-xs">🏅</span>
                    <span v-if="isDayAllClear(dayItem.dateKey, dayItem.subjects)" title="全科完成" class="text-xs">🌟</span>
                  </div>
                </div>

                <!-- 該日必複習科目列表 -->
                <div class="space-y-1">
                  <div 
                    v-for="subj in dayItem.subjects" 
                    :key="subj"
                    @click.stop="toggleSubjectDone(dayItem.dateKey, subj)"
                    class="flex items-center gap-1.5 text-[11px] px-1.5 py-0.5 rounded transition hover:bg-slate-100"
                    :class="isSubjectDone(dayItem.dateKey, subj) ? 'text-emerald-700 font-bold line-through bg-emerald-50/80' : 'text-slate-700'"
                  >
                    <span>{{ isSubjectDone(dayItem.dateKey, subj) ? '☑' : '☐' }}</span>
                    <span>{{ subj }}</span>
                  </div>
                </div>
              </div>

              <!-- 底部完成度小字 -->
              <div class="mt-2 pt-1.5 border-t border-slate-100 flex items-center justify-between text-[10px] text-slate-400">
                <span>進度 {{ getDayDoneCount(dayItem.dateKey, dayItem.subjects) }}/{{ dayItem.subjects.length }}</span>
                <span class="text-indigo-600 font-semibold hover:underline">詳情 ▶</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ==================================================== -->
      <!-- 分頁 3：🏫 717 班級課表 (真實 7 節課表) -->
      <!-- ==================================================== -->
      <div v-if="activeTab === 'timetable'" class="space-y-6">
        <div class="bg-white rounded-2xl p-5 sm:p-6 border border-slate-200 shadow-xs space-y-5">
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-4 border-b border-slate-100">
            <div>
              <h2 class="text-lg font-extrabold text-slate-900">
                🏫 新北市立林口國民中學 115 學年度第 1 學期 課程表（七年十七班 717）
              </h2>
              <p class="text-xs text-slate-500 mt-0.5">
                標示「🔥 主科」者為當日放學回家必複習科目。系統已自動將此課表轉為每日闖關任務！
              </p>
            </div>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-slate-800 text-white text-xs uppercase">
                  <th class="py-3 px-4 rounded-tl-xl text-center">節次</th>
                  <th class="py-3 px-4">時間</th>
                  <th class="py-3 px-4 text-center">週一</th>
                  <th class="py-3 px-4 text-center">週二</th>
                  <th class="py-3 px-4 text-center">週三</th>
                  <th class="py-3 px-4 text-center">週四</th>
                  <th class="py-3 px-4 rounded-tr-xl text-center">週五</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-200 text-xs sm:text-sm">
                <tr 
                  v-for="row in CLASS_717_TIMETABLE" 
                  :key="row.period"
                  :class="row.isBreak ? 'bg-amber-50/70 font-bold text-amber-900' : 'hover:bg-slate-50'"
                >
                  <td class="py-3 px-4 font-extrabold text-center text-slate-700">{{ row.period }}</td>
                  <td class="py-3 px-4 text-xs text-slate-500 font-mono whitespace-nowrap">{{ row.time }}</td>
                  <template v-if="row.isBreak">
                    <td colspan="5" class="py-3 px-4 text-center tracking-widest text-xs font-bold text-amber-800">
                      🍱 午餐與午休時間（補充體力，下午繼續奮戰！）
                    </td>
                  </template>
                  <template v-else>
                    <td 
                      v-for="dKey in ['mon', 'tue', 'wed', 'thu', 'fri']" 
                      :key="dKey"
                      class="py-3 px-3 text-center"
                    >
                      <span 
                        class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg font-bold text-xs"
                        :class="row[dKey].isMain 
                          ? 'bg-indigo-50 text-indigo-800 border border-indigo-200 shadow-2xs' 
                          : 'text-slate-500'"
                      >
                        <span v-if="row[dKey].isMain" class="text-[10px]">🔥</span>
                        {{ row[dKey].name }}
                      </span>
                    </td>
                  </template>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- 課後複習對應總覽 -->
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 pt-3">
            <div 
              v-for="(rule, dayNum) in DAILY_REVIEW_RULES" 
              :key="dayNum"
              class="p-3.5 rounded-xl bg-slate-50 border border-slate-200"
            >
              <div class="flex items-center justify-between mb-1.5">
                <span class="font-extrabold text-xs text-slate-800">{{ rule.dayName }}必複習</span>
                <span class="text-[10px] px-2 py-0.5 bg-indigo-100 text-indigo-700 rounded-full font-bold">{{ rule.tag }}</span>
              </div>
              <div class="flex flex-wrap gap-1.5">
                <span 
                  v-for="s in rule.subjects" 
                  :key="s"
                  class="px-2 py-0.5 text-xs font-bold bg-white border border-slate-200 rounded-md text-slate-700"
                >
                  {{ getSubjectMeta(s).icon }} {{ s }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ==================================================== -->
      <!-- 分頁 4：👨‍👩‍👧 家長與老師簽核中心 + 寶箱扭蛋機 -->
      <!-- ==================================================== -->
      <div v-if="activeTab === 'parent'" class="space-y-6">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- 左側：家長/導師數位聯絡簿戰報卡 & 一鍵 LINE 複製 & 當面簽章 -->
          <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-xs space-y-5">
            <div class="flex items-center justify-between pb-3 border-b border-slate-100">
              <div>
                <h2 class="text-lg font-extrabold text-slate-900 flex items-center gap-2">
                  <span>📝</span> 家長與老師簽核驗收中心
                </h2>
                <p class="text-xs text-slate-500 mt-0.5">
                  讓家長與導師清楚掌握每日複習成果，支援防偽驗收碼與當面 PIN 碼蓋章
                </p>
              </div>
              <span 
                class="px-3 py-1 rounded-full text-xs font-extrabold"
                :class="isSelectedDayParentVerified ? 'bg-amber-100 text-amber-800 border border-amber-300' : 'bg-slate-100 text-slate-600'"
              >
                {{ isSelectedDayParentVerified ? '🏅 家長已簽核認證' : '⏳ 待家長簽核' }}
              </span>
            </div>

            <!-- 數位聯絡簿預覽框 -->
            <div class="bg-slate-900 text-slate-100 rounded-xl p-4 font-mono text-xs leading-relaxed whitespace-pre-wrap border border-slate-700">
{{ parentReportText }}</div>

            <!-- 兩大行動：複製 LINE 戰報 + 家長當面蓋章 -->
            <div class="flex flex-col sm:flex-row gap-3">
              <button 
                @click="copyReportToClipboard"
                class="flex-1 py-3 px-4 bg-emerald-600 hover:bg-emerald-700 text-white font-extrabold text-xs rounded-xl shadow-sm transition flex items-center justify-center gap-2"
              >
                <span>📲</span>
                <span>{{ copySuccess ? '✅ 已複製！可直接貼上 LINE 群組' : '一鍵複製 LINE 複習回報訊息' }}</span>
              </button>

              <button 
                v-if="!isSelectedDayParentVerified"
                @click="showParentPinModal = true"
                class="flex-1 py-3 px-4 bg-gradient-to-r from-amber-400 to-orange-400 hover:from-amber-500 hover:to-orange-500 text-slate-950 font-extrabold text-xs rounded-xl shadow-sm transition flex items-center justify-center gap-2"
              >
                <span>✍️</span>
                <span>家長當面簽章認證 (領 +50金幣 & 扭蛋券)</span>
              </button>
            </div>

            <div class="pt-3 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
              <span>📊 需要繳交整月紀錄給導師嗎？</span>
              <button 
                @click="exportExcelCsv" 
                class="font-bold text-indigo-600 hover:underline flex items-center gap-1"
              >
                📥 點此下載 Excel 相容總表 (.csv)
              </button>
            </div>
          </div>

          <!-- 右側：🎁 勇者傳奇寶箱扭蛋機 & 獎勵兌換背包 -->
          <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-xs space-y-5 flex flex-col justify-between">
            <div class="space-y-4">
              <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                <div>
                  <h2 class="text-lg font-extrabold text-slate-900 flex items-center gap-2">
                    <span>🎁</span> 717 勇者寶箱扭蛋機
                  </h2>
                  <p class="text-xs text-slate-500 mt-0.5">
                    完成每日全科複習或取得家長簽章，即可獲得扭蛋券抽取獎勵！
                  </p>
                </div>
                <div class="text-right">
                  <span class="text-xs font-bold text-pink-600 bg-pink-50 px-2.5 py-1 rounded-full border border-pink-200">
                    持有扭蛋券：🎟️ {{ profile.gachaTickets }} 張
                  </span>
                </div>
              </div>

              <!-- 扭蛋舞台 -->
              <div class="bg-gradient-to-br from-indigo-950 via-purple-900 to-indigo-900 rounded-2xl p-5 text-white text-center space-y-3 border border-purple-700/40">
                <div class="text-5xl animate-pulse">🧰</div>
                <h3 class="text-base font-extrabold">傳奇榮譽寶箱</h3>
                <p class="text-xs text-indigo-200 max-w-sm mx-auto">
                  消耗 <strong class="text-amber-300">1 張扭蛋券</strong> 或 <strong class="text-amber-300">100 金幣</strong> 即可開啟一次寶箱，把心儀獎勵收進背包請家長兌換！
                </p>
                <div class="flex justify-center gap-3 pt-2">
                  <button 
                    @click="drawGacha('ticket')"
                    :disabled="profile.gachaTickets <= 0"
                    class="px-4 py-2 rounded-xl text-xs font-extrabold transition shadow-sm"
                    :class="profile.gachaTickets > 0 
                      ? 'bg-pink-500 hover:bg-pink-600 text-white' 
                      : 'bg-slate-700 text-slate-400 cursor-not-allowed'"
                  >
                    🎟️ 用 1 張扭蛋券抽獎
                  </button>
                  <button 
                    @click="drawGacha('coins')"
                    :disabled="profile.coins < 100"
                    class="px-4 py-2 rounded-xl text-xs font-extrabold transition shadow-sm"
                    :class="profile.coins >= 100 
                      ? 'bg-amber-400 hover:bg-amber-500 text-slate-950' 
                      : 'bg-slate-700 text-slate-400 cursor-not-allowed'"
                  >
                    💰 用 100 金幣抽獎
                  </button>
                </div>
              </div>

              <!-- 抽獎結果提示 -->
              <div 
                v-if="lastDrawnReward" 
                class="p-3.5 rounded-xl bg-amber-50 border-2 border-amber-300 text-amber-950 flex items-center justify-between animate-bounce"
              >
                <div class="text-xs font-bold">
                  🎉 恭喜抽中：【{{ lastDrawnReward.rarity }}】{{ lastDrawnReward.name }}！
                </div>
                <button @click="lastDrawnReward = null" class="text-xs text-amber-700 font-bold">✕</button>
              </div>

              <!-- 已獲得的獎勵券背包 -->
              <div>
                <h4 class="text-xs font-extrabold text-slate-700 mb-2">🎒 我的獎勵兌換券背包（共 {{ profile.inventory.length }} 項）：</h4>
                <div v-if="profile.inventory.length === 0" class="text-xs text-slate-400 py-4 text-center bg-slate-50 rounded-xl">
                  目前背包還沒有獎勵券，快去完成今日複習抽寶箱吧！
                </div>
                <div v-else class="space-y-2 max-h-44 overflow-y-auto pr-1">
                  <div 
                    v-for="(item, idx) in profile.inventory" 
                    :key="idx"
                    class="flex items-center justify-between p-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs"
                  >
                    <div class="flex items-center gap-2">
                      <span class="px-1.5 py-0.5 text-[10px] font-black rounded bg-indigo-600 text-white">{{ item.rarity }}</span>
                      <span class="font-bold text-slate-800">{{ item.name }}</span>
                    </div>
                    <button 
                      @click="useRewardItem(idx)"
                      class="px-2.5 py-1 bg-emerald-100 hover:bg-emerald-200 text-emerald-800 font-bold rounded-lg text-[11px]"
                    >
                      兌換使用
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

    </main>

    <!-- ==================================================== -->
    <!-- 彈窗 1：⚡ 科目快問快答驗收小遊戲 (隨機 3 題連擊 Boss 暴擊挑戰) -->
    <!-- ==================================================== -->
    <div 
      v-if="quizModal.open" 
      class="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 overflow-y-auto"
    >
      <div class="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-slate-200 space-y-4 my-auto">
        <div class="flex items-center justify-between pb-3 border-b border-slate-100">
          <div class="flex items-center gap-2.5">
            <span class="text-3xl">{{ getSubjectMeta(quizModal.subject).monsterEmoji }}</span>
            <div>
              <div class="flex items-center gap-2">
                <span class="text-[11px] font-extrabold text-rose-600 uppercase">⚡ 複習驗收三連擊暴擊戰</span>
                <span class="px-2 py-0.5 text-[10px] font-bold bg-amber-100 text-amber-800 rounded-full">
                  題庫共 {{ quizModal.totalBankSize }} 題
                </span>
              </div>
              <h3 class="text-base font-extrabold text-slate-900">
                討伐 {{ getSubjectMeta(quizModal.subject).monsterName }}（{{ quizModal.subject }}科）
              </h3>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <button 
              @click="openQuizModal(quizModal.subject)"
              class="px-2.5 py-1 text-xs font-bold bg-indigo-50 hover:bg-indigo-100 text-indigo-700 rounded-lg transition"
              title="重新隨機抽 3 題"
            >
              🔄 換一組題目
            </button>
            <button @click="quizModal.open = false" class="text-slate-400 hover:text-slate-600 font-bold text-lg px-1">✕</button>
          </div>
        </div>

        <!-- 步驟一：自我複習檢核勾選 -->
        <div class="bg-indigo-50/70 border border-indigo-200 rounded-xl p-3 space-y-1.5">
          <p class="text-xs font-extrabold text-indigo-950">🛡️ 第一關：勇者誠實自我檢核</p>
          <label class="flex items-center gap-2 text-xs text-indigo-900 cursor-pointer">
            <input type="checkbox" v-model="quizModal.selfCheck1" class="rounded text-indigo-600" />
            <span>我已經把今天學校上課的【{{ quizModal.subject }}】課本與筆記完整看過一遍</span>
          </label>
          <label class="flex items-center gap-2 text-xs text-indigo-900 cursor-pointer">
            <input type="checkbox" v-model="quizModal.selfCheck2" class="rounded text-indigo-600" />
            <span>我能夠不看課本，跟家人或自己說出今天這科的至少 2 個重點</span>
          </label>
        </div>

        <!-- 步驟二：隨機 3 題連擊快問快答 -->
        <div v-if="currentQuizQuestion" class="space-y-3">
          <div class="flex items-center justify-between">
            <p class="text-xs font-extrabold text-slate-700">
              ⚔️ 第二關：七年級核心觀念三連擊（第 <span class="text-indigo-600 text-sm">{{ quizModal.currentIndex + 1 }}</span> / {{ quizModal.questions.length }} 題）
            </p>
            <div class="flex items-center gap-1.5">
              <span 
                v-for="(qItem, qIdx) in quizModal.questions" 
                :key="qIdx"
                class="w-6 h-6 rounded-full text-[11px] font-extrabold flex items-center justify-center border"
                :class="qIdx === quizModal.currentIndex 
                  ? 'bg-indigo-600 text-white border-indigo-600 ring-2 ring-indigo-200' 
                  : (quizModal.results[qIdx] === true ? 'bg-emerald-500 text-white border-emerald-500' : (quizModal.results[qIdx] === false ? 'bg-rose-500 text-white border-rose-500' : 'bg-slate-100 text-slate-500 border-slate-200'))"
              >
                {{ qIdx + 1 }}
              </span>
            </div>
          </div>

          <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200 text-sm font-bold text-slate-900 leading-relaxed">
            {{ currentQuizQuestion.q }}
          </div>

          <div class="grid grid-cols-1 gap-2">
            <button
              v-for="(opt, idx) in currentQuizQuestion.options"
              :key="idx"
              @click="selectQuizAnswer(idx)"
              class="text-left px-4 py-2.5 rounded-xl border text-xs font-bold transition flex items-center justify-between"
              :class="getQuizOptionClass(idx)"
            >
              <span>{{ ['A', 'B', 'C', 'D'][idx] }}. {{ opt }}</span>
              <span v-if="quizModal.selectedIdx === idx">
                {{ idx === currentQuizQuestion.answer ? '✅' : '❌' }}
              </span>
            </button>
          </div>

          <!-- 答題解析回饋與下一題按鈕 -->
          <div 
            v-if="quizModal.answered" 
            class="p-3.5 rounded-xl text-xs leading-relaxed space-y-2"
            :class="quizModal.isCorrect ? 'bg-emerald-50 text-emerald-900 border border-emerald-200' : 'bg-rose-50 text-rose-900 border border-rose-200'"
          >
            <div class="flex items-center justify-between">
              <p class="font-extrabold">
                {{ quizModal.isCorrect ? `💥 暴擊命中！（累計答對 ${quizModal.correctCount}/${quizModal.questions.length} 題）` : '💡 差一點點！看解析學起來一樣能過關：' }}
              </p>
              <button 
                v-if="quizModal.currentIndex < quizModal.questions.length - 1"
                @click="nextQuizQuestion"
                class="px-3 py-1 bg-indigo-600 hover:bg-indigo-700 text-white font-extrabold rounded-lg shadow-xs animate-pulse"
              >
                下一題 ({{ quizModal.currentIndex + 2 }}/{{ quizModal.questions.length }}) ▶
              </button>
            </div>
            <p>{{ currentQuizQuestion.exp }}</p>
          </div>
        </div>

        <div class="pt-2 flex items-center justify-between gap-2 border-t border-slate-100">
          <span class="text-xs font-bold text-slate-500">
            已完成：{{ quizModal.answeredCount }} / {{ quizModal.questions.length }} 題
          </span>
          <div class="flex gap-2">
            <button 
              @click="quizModal.open = false"
              class="px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-100 rounded-xl"
            >
              先關閉
            </button>
            <button 
              v-if="quizModal.answered && quizModal.currentIndex < quizModal.questions.length - 1"
              @click="nextQuizQuestion"
              class="px-5 py-2 text-xs font-extrabold rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white shadow-sm"
            >
              前往下一題 ▶
            </button>
            <button 
              v-else
              @click="completeQuizChallenge"
              :disabled="!quizModal.selfCheck1 || !quizModal.selfCheck2 || quizModal.answeredCount < quizModal.questions.length"
              class="px-5 py-2 text-xs font-extrabold rounded-xl shadow-sm transition"
              :class="(quizModal.selfCheck1 && quizModal.selfCheck2 && quizModal.answeredCount >= quizModal.questions.length)
                ? 'bg-gradient-to-r from-amber-400 to-orange-500 text-slate-950 hover:from-amber-500 hover:to-orange-600'
                : 'bg-slate-200 text-slate-400 cursor-not-allowed'"
            >
              🏆 完成三連擊領雙倍獎勵 (+{{ 30 + quizModal.correctCount * 10 }} EXP & +30金幣)
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ==================================================== -->
    <!-- 彈窗 2：✍️ 家長當面簽章認證 (PIN 碼驗證) -->
    <!-- ==================================================== -->
    <div 
      v-if="showParentPinModal" 
      class="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50"
    >
      <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-4">
        <div class="flex items-center justify-between pb-2 border-b border-slate-100">
          <h3 class="text-base font-extrabold text-slate-900 flex items-center gap-1.5">
            <span>🏅</span> 家長 / 導師當面簽章認證
          </h3>
          <button @click="showParentPinModal = false" class="text-slate-400 hover:text-slate-600">✕</button>
        </div>

        <p class="text-xs text-slate-600 leading-relaxed">
          請家長或老師確認孩子已完成 <strong>{{ selectedDateKey }}</strong> 的課後複習後，輸入簽核密碼（預設為班級代號 <code class="px-1.5 py-0.5 bg-slate-100 rounded font-bold text-indigo-700">{{ profile.parentPin }}</code>）蓋上榮譽印章！
        </p>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">請輸入家長簽核 PIN 碼：</label>
          <input 
            type="password" 
            v-model="parentPinInput"
            placeholder="預設密碼：0717"
            class="w-full px-3.5 py-2.5 text-center text-lg tracking-widest font-mono border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:outline-none"
          />
          <p v-if="parentPinError" class="text-xs text-rose-600 font-bold mt-1">{{ parentPinError }}</p>
        </div>

        <div>
          <label class="block text-xs font-bold text-slate-700 mb-1">家長鼓勵評語（選填）：</label>
          <input 
            type="text" 
            v-model="parentCommentInput"
            placeholder="例如：今天很認真主動複習，繼續保持！"
            class="w-full px-3 py-2 text-xs border border-slate-300 rounded-xl"
          />
        </div>

        <div class="pt-2 flex justify-end gap-2">
          <button 
            @click="showParentPinModal = false"
            class="px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-100 rounded-xl"
          >
            取消
          </button>
          <button 
            @click="verifyParentPin"
            class="px-5 py-2 text-xs font-extrabold bg-amber-400 hover:bg-amber-500 text-slate-950 rounded-xl shadow-sm"
          >
            ✍️ 確認蓋章並發送獎勵 (+50金幣 & 扭蛋券x1)
          </button>
        </div>
      </div>
    </div>

    <!-- ==================================================== -->
    <!-- 彈窗 3：學生與家長設定視窗 -->
    <!-- ==================================================== -->
    <div 
      v-if="showProfileModal" 
      class="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50"
    >
      <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-4">
        <div class="flex items-center justify-between pb-2 border-b border-slate-100">
          <h3 class="text-base font-extrabold text-slate-900">⚙️ 717 班學生資料與家長密碼設定</h3>
          <button @click="showProfileModal = false" class="text-slate-400 hover:text-slate-600">✕</button>
        </div>

        <div class="space-y-3">
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">七年十七班 座號：</label>
            <input v-model="profile.seatNo" type="text" class="w-full px-3 py-2 text-xs border border-slate-300 rounded-lg" />
          </div>
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">學生姓名 / 勇者暱稱：</label>
            <input v-model="profile.studentName" type="text" class="w-full px-3 py-2 text-xs border border-slate-300 rounded-lg" />
          </div>
          <div>
            <label class="block text-xs font-bold text-slate-700 mb-1">家長簽章 PIN 碼（預設 0717）：</label>
            <input v-model="profile.parentPin" type="text" class="w-full px-3 py-2 text-xs border border-slate-300 rounded-lg" />
          </div>
        </div>

        <div class="pt-2 flex justify-end">
          <button 
            @click="saveProfileAndClose"
            class="px-5 py-2 text-xs font-extrabold bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl"
          >
            儲存設定
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import confetti from 'canvas-confetti';
import {
  CLASS_717_TIMETABLE,
  DAILY_REVIEW_RULES,
  SUBJECT_META,
  SUBJECT_QUIZ_BANK,
  PET_STAGES,
  GACHA_REWARDS,
  generateMonthSchedule
} from './data/class717Data.js';

// 導覽分頁
const activeTab = ref('daily');
const navTabs = computed(() => [
  { id: 'daily', icon: '⚔️', label: '今日複習闖關', badge: remainingTaskCount.value > 0 ? `待完成 ${remainingTaskCount.value}` : 'CLEAR!' },
  { id: 'calendar', icon: '📅', label: '1~12月 CheckList 月曆表' },
  { id: 'timetable', icon: '🏫', label: '717 班級課表' },
  { id: 'parent', icon: '👨‍👩‍👧', label: '家長與老師簽核 / 寶箱扭蛋' }
]);

// 當前選定日期（預設今日 2026-10-22 星期四，完美對應使用者系統時間與 Excel 10/22）
const selectedDateKey = ref('2026-10-22');
const calendarYear = ref(2026);
const calendarMonth = ref(10);

// 學生個人檔案與 RPG 狀態
const profile = ref({
  seatNo: '17',
  studentName: '林口小勇者',
  exp: 120,
  coins: 85,
  gachaTickets: 1,
  parentPin: '0717',
  inventory: [
    { id: 'init1', rarity: 'R', name: '⚔️ 勇者爆擊稱號【717 複習連勝王】' }
  ]
});

// 儲存所有日期的打卡記錄：{ '2026-10-22': { subjects: { '國文': { done: true, note: '...', quizPassed: true } }, parentVerified: false, parentComment: '', verifiedTime: '' } }
const reviewRecords = ref({});

// 動態產生所選年份與月份 (1~12月) 的排程
const currentMonthSchedule = computed(() => {
  return generateMonthSchedule(calendarYear.value, calendarMonth.value);
});

// 計算該月 1 號是星期幾，用於補齊月曆前導空格
const calendarLeadingEmptyCount = computed(() => {
  const firstDayObj = new Date(calendarYear.value, calendarMonth.value - 1, 1);
  return firstDayObj.getDay();
});

// 計算指定年月的全科完成 (All Clear) 天數
function getMonthClearCount(year, month) {
  const schedule = generateMonthSchedule(year, month);
  let count = 0;
  for (const d of schedule) {
    if (isDayAllClear(d.dateKey, d.subjects)) {
      count++;
    }
  }
  return count;
}

// 計算勇者等級與神獸進化型態
const heroLevel = computed(() => Math.floor(profile.value.exp / 100) + 1);
const currentPet = computed(() => {
  let stage = PET_STAGES[0];
  for (const s of PET_STAGES) {
    if (heroLevel.value >= s.minLv) {
      stage = s;
    }
  }
  return stage;
});

// 當前選定日期的資訊
const selectedDayInfo = computed(() => {
  const parts = selectedDateKey.value.split('-');
  const y = Number(parts[0]);
  const m = Number(parts[1]);
  const d = Number(parts[2]);
  const dateObj = new Date(y, m - 1, d);
  const dow = dateObj.getDay();
  const rule = DAILY_REVIEW_RULES[dow];
  return {
    year: y,
    month: m,
    day: d,
    dayOfWeek: dow,
    dayName: rule.dayName,
    tag: rule.tag,
    subjects: rule.subjects
  };
});

// 當前選定日期的各科任務狀態清單
const currentDayTasks = computed(() => {
  const dateKey = selectedDateKey.value;
  const dayRec = reviewRecords.value[dateKey]?.subjects || {};
  return selectedDayInfo.value.subjects.map(subj => {
    const item = dayRec[subj] || { done: false, note: '', quizPassed: false };
    return {
      subject: subj,
      done: !!item.done,
      note: item.note || '',
      quizPassed: !!item.quizPassed
    };
  });
});

// 今日剩餘未完成科目數與魔王血量
const remainingTaskCount = computed(() => {
  return currentDayTasks.value.filter(t => !t.done).length;
});

const bossHpPercent = computed(() => {
  const total = currentDayTasks.value.length;
  if (total === 0) return 0;
  return Math.round((remainingTaskCount.value / total) * 100);
});

// 計算總共全制霸的天數 (統計全年度 1~12 月)
const totalClearDays = computed(() => {
  let count = 0;
  for (let m = 1; m <= 12; m++) {
    count += getMonthClearCount(calendarYear.value, m);
  }
  return count;
});

// 取得科目元資料
function getSubjectMeta(subj) {
  return SUBJECT_META[subj] || {
    icon: '📘',
    colorClass: 'bg-slate-50 text-slate-700 border-slate-200',
    badgeClass: 'bg-slate-600 text-white',
    monsterName: '未知迷霧怪',
    monsterEmoji: '👾',
    guide: '複習今日課堂筆記與習作題目'
  };
}

// 確保該日期記錄物件已初始化
function ensureDateRecord(dateKey) {
  if (!reviewRecords.value[dateKey]) {
    reviewRecords.value[dateKey] = {
      subjects: {},
      parentVerified: false,
      parentComment: '',
      verifiedTime: ''
    };
  }
  if (!reviewRecords.value[dateKey].subjects) {
    reviewRecords.value[dateKey].subjects = {};
  }
}

// 切換某日某科的完成狀態
function toggleSubjectDone(dateKey, subject) {
  ensureDateRecord(dateKey);
  const current = reviewRecords.value[dateKey].subjects[subject] || { done: false, note: '', quizPassed: false };
  const nextDone = !current.done;
  reviewRecords.value[dateKey].subjects[subject] = {
    ...current,
    done: nextDone
  };

  if (nextDone) {
    profile.value.exp += 25;
    profile.value.coins += 15;
    triggerConfetti(45);

    // 若該日全部科目都完成了，額外送 1 張扭蛋券
    const parts = dateKey.split('-');
    const dow = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2])).getDay();
    const reqSubjects = DAILY_REVIEW_RULES[dow].subjects;
    if (isDayAllClear(dateKey, reqSubjects)) {
      profile.value.gachaTickets += 1;
      triggerConfetti(100);
    }
  }
  saveAllToStorage();
}

// 儲存備註
function saveNote(dateKey, subject, noteText) {
  ensureDateRecord(dateKey);
  const current = reviewRecords.value[dateKey].subjects[subject] || { done: false, note: '', quizPassed: false };
  reviewRecords.value[dateKey].subjects[subject] = {
    ...current,
    note: noteText
  };
  saveAllToStorage();
}

// 判斷某日某科是否完成
function isSubjectDone(dateKey, subject) {
  return !!reviewRecords.value[dateKey]?.subjects?.[subject]?.done;
}

// 計算某日已完成科數
function getDayDoneCount(dateKey, subjects) {
  return subjects.filter(s => isSubjectDone(dateKey, s)).length;
}

// 判斷某日是否全科 All Clear
function isDayAllClear(dateKey, subjects) {
  if (!subjects || subjects.length === 0) return false;
  return getDayDoneCount(dateKey, subjects) === subjects.length;
}

// 判斷某日是否已獲家長簽章
function isDayParentVerified(dateKey) {
  return !!reviewRecords.value[dateKey]?.parentVerified;
}

const isSelectedDayParentVerified = computed(() => isDayParentVerified(selectedDateKey.value));

// 日期切換輔助
function shiftSelectedDate(deltaDays) {
  const parts = selectedDateKey.value.split('-');
  const d = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
  d.setDate(d.getDate() + deltaDays);
  const yy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  selectedDateKey.value = `${yy}-${mm}-${dd}`;
}

function resetToToday() {
  selectedDateKey.value = '2026-10-22';
}

function selectDateFromCalendar(dateKey) {
  selectedDateKey.value = dateKey;
  activeTab.value = 'daily';
}

// ====================================================
// 快問快答驗收小遊戲邏輯 (隨機洗牌抽 3 題連擊模式)
// ====================================================
const quizModal = ref({
  open: false,
  subject: '國文',
  totalBankSize: 0,
  selfCheck1: true,
  selfCheck2: true,
  questions: [],
  currentIndex: 0,
  results: [],
  selectedIdx: null,
  answered: false,
  isCorrect: false,
  answeredCount: 0,
  correctCount: 0
});

const currentQuizQuestion = computed(() => {
  return quizModal.value.questions[quizModal.value.currentIndex] || null;
});

function openQuizModal(subject) {
  const bank = SUBJECT_QUIZ_BANK[subject] || SUBJECT_QUIZ_BANK['錯題訂正'];
  // Fisher-Yates 隨機洗牌抽出 3 題不重複題目
  const shuffled = [...bank];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  const pickedQuestions = shuffled.slice(0, Math.min(3, shuffled.length));

  quizModal.value = {
    open: true,
    subject,
    totalBankSize: bank.length,
    selfCheck1: true,
    selfCheck2: true,
    questions: pickedQuestions,
    currentIndex: 0,
    results: new Array(pickedQuestions.length).fill(null),
    selectedIdx: null,
    answered: false,
    isCorrect: false,
    answeredCount: 0,
    correctCount: 0
  };
}

function selectQuizAnswer(idx) {
  if (quizModal.value.answered || !currentQuizQuestion.value) return;
  quizModal.value.selectedIdx = idx;
  quizModal.value.answered = true;
  const correct = idx === currentQuizQuestion.value.answer;
  quizModal.value.isCorrect = correct;
  quizModal.value.results[quizModal.value.currentIndex] = correct;
  quizModal.value.answeredCount += 1;
  if (correct) {
    quizModal.value.correctCount += 1;
    triggerConfetti(55);
  }
}

function nextQuizQuestion() {
  if (quizModal.value.currentIndex < quizModal.value.questions.length - 1) {
    quizModal.value.currentIndex += 1;
    quizModal.value.selectedIdx = null;
    quizModal.value.answered = false;
    quizModal.value.isCorrect = false;
  }
}

function getQuizOptionClass(idx) {
  if (!quizModal.value.answered || !currentQuizQuestion.value) {
    return 'bg-white border-slate-200 hover:border-indigo-400 hover:bg-indigo-50/40 text-slate-800';
  }
  if (idx === currentQuizQuestion.value.answer) {
    return 'bg-emerald-50 border-emerald-400 text-emerald-900';
  }
  if (idx === quizModal.value.selectedIdx) {
    return 'bg-rose-50 border-rose-300 text-rose-800';
  }
  return 'bg-slate-50 border-slate-200 text-slate-400';
}

function completeQuizChallenge() {
  const dateKey = selectedDateKey.value;
  const subject = quizModal.value.subject;
  const earnedExp = 30 + quizModal.value.correctCount * 10;
  ensureDateRecord(dateKey);
  const current = reviewRecords.value[dateKey].subjects[subject] || { done: false, note: '', quizPassed: false };
  reviewRecords.value[dateKey].subjects[subject] = {
    ...current,
    done: true,
    quizPassed: true,
    note: current.note || `完成${subject}課後複習並通過三連擊驗收 (答對 ${quizModal.value.correctCount}/${quizModal.value.questions.length} 題)`
  };

  profile.value.exp += earnedExp;
  profile.value.coins += 30;
  quizModal.value.open = false;
  triggerConfetti(100);
  saveAllToStorage();
}

// ====================================================
// 家長聯絡簿戰報與當面 PIN 碼簽章
// ====================================================
const showParentPinModal = ref(false);
const parentPinInput = ref('');
const parentCommentInput = ref('');
const parentPinError = ref('');
const copySuccess = ref(false);

// 防偽驗收碼生成
const verificationCode = computed(() => {
  const dateCompact = selectedDateKey.value.replace(/-/g, '').slice(4);
  const doneStr = currentDayTasks.value.map(t => (t.done ? '1' : '0')).join('');
  const hash = (Number(dateCompact) * 17 + parseInt(doneStr || '0', 2) * 31)
    .toString(16)
    .toUpperCase()
    .padStart(4, '0');
  return `LK717-${dateCompact}-${hash}`;
});

// 數位聯絡簿戰報文字
const parentReportText = computed(() => {
  const info = selectedDayInfo.value;
  const tasks = currentDayTasks.value;
  const doneCount = tasks.filter(t => t.done).length;
  const rec = reviewRecords.value[selectedDateKey.value] || {};

  const taskLines = tasks.map(t => {
    const statusIcon = t.done ? '✔ 已完成' : '☐ 未完成';
    const quizTag = t.quizPassed ? ' [⚡通過快問快答]' : '';
    const noteStr = t.note ? `（進度：${t.note}）` : '';
    return `  ・[${statusIcon}] ${t.subject}${quizTag}${noteStr}`;
  }).join('\n');

  const verifyLine = rec.parentVerified
    ? `🏅 家長簽核狀態：✅ 家長已當面簽章認證 (${rec.verifiedTime})\n💬 家長評語：${rec.parentComment || '表現優秀，繼續保持！'}`
    : `⏳ 家長簽核狀態：待家長檢視簽章`;

  return `【林口國中 七年十七班・每日課後複習回報單】
📅 複習日期：${selectedDateKey.value} (${info.dayName})
🦸 學生身分：717班 ${profile.value.seatNo}號 ${profile.value.studentName} (Lv.${heroLevel.value} ${currentPet.value.title})
📊 完成進度：${doneCount} / ${tasks.length} 科 (${Math.round((doneCount / tasks.length) * 100)}%)
----------------------------------------
${taskLines}
----------------------------------------
${verifyLine}
🔐 系統防偽驗收碼：#${verificationCode.value}`;
});

function verifyParentPin() {
  if (parentPinInput.value.trim() !== profile.value.parentPin) {
    parentPinError.value = '密碼不正確！（提示：預設為 0717）';
    return;
  }
  ensureDateRecord(selectedDateKey.value);
  const now = new Date();
  const hh = String(now.getHours()).padStart(2, '0');
  const mm = String(now.getMinutes()).padStart(2, '0');

  reviewRecords.value[selectedDateKey.value].parentVerified = true;
  reviewRecords.value[selectedDateKey.value].parentComment = parentCommentInput.value.trim() || '家長已確認完成今日複習！';
  reviewRecords.value[selectedDateKey.value].verifiedTime = `${hh}:${mm}`;

  profile.value.coins += 50;
  profile.value.gachaTickets += 1;

  parentPinInput.value = '';
  parentPinError.value = '';
  showParentPinModal.value = false;
  triggerConfetti(120);
  saveAllToStorage();
}

async function copyReportToClipboard() {
  try {
    await navigator.clipboard.writeText(parentReportText.value);
    copySuccess.value = true;
    setTimeout(() => {
      copySuccess.value = false;
    }, 3000);
  } catch (e) {
    console.error('複製失敗', e);
  }
}

// 匯出相容於《林口國中_七年十七班_每日複習CheckList.xlsx》的 CSV 報表 (支援單月或全年 1~12 月)
function exportExcelCsv(mode = 'year') {
  const headers = ['日期', '星期', '科目', '複習狀態(1=完成,0=未完成)', '快問快答驗收', '備註/完成進度', '家長簽章'];
  const rows = [headers.join(',')];
  const allDays = [];

  if (mode === 'month') {
    allDays.push(...generateMonthSchedule(calendarYear.value, calendarMonth.value));
  } else {
    for (let m = 1; m <= 12; m++) {
      allDays.push(...generateMonthSchedule(calendarYear.value, m));
    }
  }

  for (const d of allDays) {
    const rec = reviewRecords.value[d.dateKey] || {};
    const verifiedStr = rec.parentVerified ? `已簽核(${rec.verifiedTime})` : '未簽核';
    for (const subj of d.subjects) {
      const sRec = rec.subjects?.[subj] || {};
      const doneVal = sRec.done ? 1 : 0;
      const quizVal = sRec.quizPassed ? '通過' : '-';
      const noteClean = (sRec.note || '').replace(/,/g, '，');
      rows.push([d.dateKey, d.dayName, subj, doneVal, quizVal, noteClean, verifiedStr].join(','));
    }
  }

  // 加入 UTF-8 BOM 確保 Excel 打開繁體中文不亂碼
  const csvContent = '\uFEFF' + rows.join('\n');
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  const rangeLabel = mode === 'month' ? `${calendarYear.value}年${calendarMonth.value}月` : `${calendarYear.value}全年1至12月`;
  a.download = `林口國中_七年十七班_${profile.value.seatNo}號_${profile.value.studentName}_${rangeLabel}_每日複習CheckList.csv`;
  a.click();
  URL.revokeObjectURL(url);
}

// ====================================================
// 寶箱扭蛋機與獎勵背包
// ====================================================
const lastDrawnReward = ref(null);

function drawGacha(costType) {
  if (costType === 'ticket') {
    if (profile.value.gachaTickets <= 0) return;
    profile.value.gachaTickets -= 1;
  } else {
    if (profile.value.coins < 100) return;
    profile.value.coins -= 100;
  }

  const picked = GACHA_REWARDS[Math.floor(Math.random() * GACHA_REWARDS.length)];
  lastDrawnReward.value = picked;
  profile.value.inventory.unshift({ ...picked, obtainedAt: selectedDateKey.value });
  triggerConfetti(80);
  saveAllToStorage();
}

function useRewardItem(idx) {
  profile.value.inventory.splice(idx, 1);
  saveAllToStorage();
}

// ====================================================
// 勇者專注計時器 (番茄鐘)
// ====================================================
const timerSeconds = ref(15 * 60);
const timerRunning = ref(false);
let timerInterval = null;

const formattedTimer = computed(() => {
  const m = String(Math.floor(timerSeconds.value / 60)).padStart(2, '0');
  const s = String(timerSeconds.value % 60).padStart(2, '0');
  return `${m}:${s}`;
});

function setTimerMinutes(mins) {
  if (timerRunning.value) return;
  timerSeconds.value = mins * 60;
}

function toggleTimer() {
  if (timerRunning.value) {
    clearInterval(timerInterval);
    timerRunning.value = false;
  } else {
    timerRunning.value = true;
    timerInterval = setInterval(() => {
      if (timerSeconds.value > 0) {
        timerSeconds.value -= 1;
      } else {
        clearInterval(timerInterval);
        timerRunning.value = false;
        profile.value.coins += 20;
        profile.value.exp += 15;
        triggerConfetti(70);
        saveAllToStorage();
      }
    }, 1000);
  }
}

function resetTimer() {
  clearInterval(timerInterval);
  timerRunning.value = false;
  timerSeconds.value = 15 * 60;
}

// ====================================================
// 個人設定與 LocalStorage 存取
// ====================================================
const showProfileModal = ref(false);

function saveProfileAndClose() {
  showProfileModal.value = false;
  saveAllToStorage();
}

function triggerConfetti(count = 50) {
  try {
    confetti({
      particleCount: count,
      spread: 70,
      origin: { y: 0.75 }
    });
  } catch (e) {
    // 忽略環境不支援 canvas 之例外
  }
}

const STORAGE_KEY_RECORDS = 'lkjh_717_review_records_v1';
const STORAGE_KEY_PROFILE = 'lkjh_717_hero_profile_v1';

function saveAllToStorage() {
  localStorage.setItem(STORAGE_KEY_RECORDS, JSON.stringify(reviewRecords.value));
  localStorage.setItem(STORAGE_KEY_PROFILE, JSON.stringify(profile.value));
}

function loadAllFromStorage() {
  try {
    const savedRec = localStorage.getItem(STORAGE_KEY_RECORDS);
    if (savedRec) {
      reviewRecords.value = JSON.parse(savedRec);
    } else {
      // 預設將 10/01 國文設為已完成（對應您 Excel 中的示範資料 D2:1）
      reviewRecords.value = {
        '2026-10-01': {
          subjects: {
            '國文': { done: true, note: '已完成第一課課後複習', quizPassed: true }
          },
          parentVerified: true,
          parentComment: '開學第一天表現很棒！',
          verifiedTime: '20:30'
        },
        '2026-10-22': {
          subjects: {
            '國文': { done: true, note: '完成課文朗讀與圈詞注釋複習', quizPassed: true }
          },
          parentVerified: false,
          parentComment: '',
          verifiedTime: ''
        }
      };
    }

    const savedProf = localStorage.getItem(STORAGE_KEY_PROFILE);
    if (savedProf) {
      profile.value = { ...profile.value, ...JSON.parse(savedProf) };
    }
  } catch (e) {
    console.error('載入本機資料失敗', e);
  }
}

onMounted(() => {
  loadAllFromStorage();
});

onUnmounted(() => {
  if (timerInterval) clearInterval(timerInterval);
});
</script>
