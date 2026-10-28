import "./_group.css";

const menuGroups = [
  { title: "Info", apps: ["Planner", "Site News", "Photo Gallery", "Browse Users"] },
  { title: "Games", apps: ["Games Manager", "Eaglercraft", "Chess"] },
  { title: "Social", apps: ["My Page Editor", "Open Forum", "Add Chatbox", "Open DMs", "the Network"] },
  { title: "Settings", apps: ["Settings", "Add Link Shortcut", "Add Text Note"] },
];

function LegacyWindow({ title, className = "", children }: { title: string; className?: string; children: React.ReactNode }) {
  return (
    <section className={`win98-window absolute flex flex-col ${className}`}>
      <header className="win98-titlebar flex items-center justify-between">
        <span className="truncate">{title}</span>
        <div className="flex gap-1">
          {["_", "□", "×"].map((label) => (
            <button key={label} className="win98-button h-5 min-w-5 px-1 leading-none" aria-label={label}>{label}</button>
          ))}
        </div>
      </header>
      <div className="flex-1 bg-white p-3 text-slate-900">{children}</div>
    </section>
  );
}

export function CurrentMaxNetDesktop() {
  return (
    <main className="maxnet-current relative min-h-screen overflow-hidden bg-[#008080] text-[13px] text-black">
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_76%_18%,rgba(255,255,255,.16),transparent_35%),linear-gradient(135deg,#0a7777,#07585d)]" />
      <div className="absolute left-[4%] top-[6%] grid gap-4 text-center text-white drop-shadow">
        {[
          ["▣", "My Computer"],
          ["▤", "MaxNet"],
          ["♟", "Recycle Bin"],
        ].map(([icon, label]) => (
          <div key={label} className="w-20 rounded p-2">
            <div className="mx-auto mb-1 text-3xl">{icon}</div>
            <div className="text-xs">{label}</div>
          </div>
        ))}
      </div>

      <LegacyWindow title="Chatbox" className="left-[24%] top-[13%] h-[38%] w-[30%] min-w-[300px]">
        <div className="flex h-full flex-col gap-2">
          <div className="flex items-center justify-between border-b border-slate-200 pb-2">
            <div>
              <p className="font-bold">MaxNet Chatroom</p>
              <p className="text-xs text-slate-500">12 people online</p>
            </div>
            <span className="rounded border border-green-300 bg-green-50 px-2 py-1 text-xs text-green-800">Connected</span>
          </div>
          <div className="flex-1 space-y-3 overflow-hidden text-xs">
            <p><strong>maple:</strong> anyone on the Network today?</p>
            <p><strong>max_user:</strong> just got Eaglercraft running</p>
            <p><strong>river:</strong> see you in the lobby</p>
          </div>
          <div className="flex gap-2">
            <div className="flex-1 border border-slate-400 bg-white px-2 py-1 text-slate-400">Message the room…</div>
            <button className="win98-button px-3">Send</button>
          </div>
        </div>
      </LegacyWindow>

      <LegacyWindow title="the Network" className="right-[5%] top-[19%] h-[45%] w-[34%] min-w-[320px]">
        <div className="mb-3 flex items-center gap-2 border-b border-slate-200 pb-3">
          <span className="grid h-8 w-8 place-items-center rounded-lg bg-[#23655f] font-bold text-white">N</span>
          <div><p className="font-bold">the Network</p><p className="text-xs text-slate-500">Posts from your community</p></div>
        </div>
        <article className="mb-3 rounded border border-slate-200 bg-slate-50 p-3">
          <div className="flex items-center gap-2 text-xs"><span className="grid h-7 w-7 place-items-center rounded-full bg-cyan-100 font-bold text-cyan-900">M</span><strong>max_user</strong><span className="text-slate-400">· 8 min</span></div>
          <p className="mt-3 text-sm">New MaxNet setup is looking good. What apps should we add next?</p>
          <div className="mt-3 flex gap-4 text-xs text-slate-500">♡ 8　↩ 3　Share</div>
        </article>
        <button className="win98-button px-3 py-1">Open Forum</button>
      </LegacyWindow>

      <div className="absolute bottom-10 left-[28%] z-10 flex gap-3">
        <LegacyWindow title="Eaglercraft" className="h-[230px] w-[330px]">
          <div className="grid h-full place-items-center bg-[#152522] text-center text-white">
            <div><div className="text-2xl font-black tracking-[.2em] text-[#79d0b6]">EAGLERCRAFT</div><p className="mt-2 text-xs text-white/70">Minecraft in your MaxNet desktop</p><button className="mt-5 rounded bg-[#4e9b80] px-5 py-2 font-bold text-white">Join server</button></div>
          </div>
        </LegacyWindow>
      </div>

      <div className="absolute bottom-0 left-0 right-0 z-50 flex h-10 items-center gap-1 border-t-2 border-t-white bg-[#c0c0c0] px-1 shadow-[inset_0_1px_0_#dfdfdf]">
        <button className="win98-button flex h-8 items-center gap-2 px-2 font-bold">
          <span className="h-5 w-5 bg-gradient-to-br from-blue-600 to-green-500 shadow-inner" />Start
        </button>
        <div className="h-[80%] w-[2px] border-l border-[#808080] border-r border-white" />
        <button className="win98-button h-8 px-2">String</button>
        <button className="win98-button h-8 px-2">⌖ Recover windows</button>
        <button className="win98-button h-8 px-2">✉ DMs</button>
        <button className="win98-button h-8 px-2">☁ Chat</button>
        <div className="flex-1" />
        <button className="win98-button h-8 px-2">max_user [Member]</button>
        <div className="win98-button px-3 py-2 text-xs">12:42 PM</div>
      </div>

      <section className="win98-menu absolute bottom-12 left-1 z-[60] flex w-[320px] overflow-hidden">
        <div className="flex w-9 shrink-0 items-end bg-gradient-to-b from-[#000080] to-[#1084d0] p-2">
          <span className="origin-bottom-left -rotate-90 whitespace-nowrap text-xl font-bold text-white">MaxNet</span>
        </div>
        <div className="max-h-[min(610px,calc(100dvh-4.5rem))] flex-1 space-y-1 overflow-y-auto p-2">
          {menuGroups.map((group) => (
            <div key={group.title}>
              <button className="flex w-full items-center justify-between px-3 py-2 text-left hover:bg-[#000080] hover:text-white">
                <span>{group.title}</span><span>›</span>
              </button>
            </div>
          ))}
          <div className="my-2 border-t border-[#808080]" />
          <button className="w-full px-3 py-2 text-left hover:bg-[#000080] hover:text-white">Go to Home</button>
          <button className="w-full px-3 py-2 text-left hover:bg-[#000080] hover:text-white">Go to Street</button>
          <button className="w-full px-3 py-2 text-left hover:bg-[#000080] hover:text-white">Go to About</button>
        </div>
      </section>
    </main>
  );
}
