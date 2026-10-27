import { useState, type CSSProperties } from "react";
import {
  BatteryFull, Bell, CalendarDays, Check, ChevronRight, Cloud, Folder,
  Gamepad2, Globe2, HardDrive, Heart, Laptop, MessageCircle, Minus, Monitor,
  Palette, Radio, Search, Settings, Shield, ShieldCheck, Square, Star, Wifi,
  WifiOff, X,
} from "lucide-react";

type AppId = "Chatbox" | "Open Forum" | "the Network" | "Eaglercraft" | "Games Manager" | "Planner" | "Settings" | "Files" | "Computer" | "Help" | "Update Center";

const themes = [
  ["classic-light", "Classic light"],
  ["classic-dark", "Classic dark"],
  ["xp-light", "Windows XP light"],
  ["xp-dark", "Windows XP dark"],
  ["vista", "Windows Vista"],
  ["vista-dark", "Windows Vista dark"],
  ["gold", "Gold picture frame"],
  ["silver", "Silver picture frame"],
] as const;

const appCatalog: { name: AppId; icon: typeof MessageCircle; color: string; detail: string }[] = [
  { name: "Chatbox", icon: MessageCircle, color: "bg-[#176b7a]", detail: "Lobby · 12 active" },
  { name: "Open Forum", icon: Radio, color: "bg-[#9b5943]", detail: "Topics and conversations" },
  { name: "the Network", icon: Globe2, color: "bg-[#237a70]", detail: "Community feed" },
  { name: "Eaglercraft", icon: Gamepad2, color: "bg-[#4f7050]", detail: "Multiplayer worlds" },
  { name: "Games Manager", icon: Star, color: "bg-[#876c37]", detail: "Your game library" },
  { name: "Planner", icon: CalendarDays, color: "bg-[#556b9a]", detail: "Plans and reminders" },
];

function AppWindow({ app, onClose, onFocus, onMinimize, onToggleMaximize, minimized, maximized, active }: {
  app: AppId;
  onClose: () => void;
  onFocus: () => void;
  onMinimize: () => void;
  onToggleMaximize: () => void;
  minimized: boolean;
  maximized: boolean;
  active: boolean;
}) {
  const windowStyle: CSSProperties = {
    display: minimized ? "none" : undefined,
    zIndex: active ? 45 : 20,
    ...(maximized ? { top: 45, left: 12, right: 12, bottom: 60, width: "auto", height: "auto" } : {}),
  };
  const commonHeader = (
    <header className="flex h-10 shrink-0 items-center justify-between border-b border-[#cad6d7] bg-[#f3f7f6] px-3">
      <div className="flex items-center gap-2 text-[13px] font-semibold text-[#23434a]">
        <span className="grid h-6 w-6 place-items-center rounded-md bg-[#d9eeee] text-[#176b7a]">
          {app === "Chatbox" ? <MessageCircle size={14} /> : app === "the Network" ? <Globe2 size={14} /> : app === "Eaglercraft" ? <Gamepad2 size={14} /> : app === "Planner" ? <CalendarDays size={14} /> : app === "Settings" ? <Settings size={14} /> : <Radio size={14} />}
        </span>
        {app}
      </div>
      <div className="flex items-center gap-1">
        <button aria-label="Minimize window" onClick={onMinimize} className="rounded p-1.5 text-[#547078] hover:bg-[#e3ecec]"><Minus size={13} /></button>
        <button aria-label={maximized ? "Restore window" : "Maximize window"} onClick={onToggleMaximize} className="rounded p-1.5 text-[#547078] hover:bg-[#e3ecec]"><Square size={12} /></button>
        <button aria-label="Close window" onClick={onClose} className="rounded p-1.5 text-[#547078] hover:bg-[#f1d9d5] hover:text-[#913d32]"><X size={14} /></button>
      </div>
    </header>
  );

  if (app === "Update Center") return (
    <section style={windowStyle} onPointerDown={onFocus} className="absolute left-[34%] top-[21%] z-40 flex h-[330px] w-[390px] flex-col overflow-hidden rounded-xl border border-white/90 bg-[#f8fbfa] text-[#233b42] shadow-[0_24px_70px_rgba(14,48,52,.30)] ring-1 ring-[#174e56]/15">
      {commonHeader}
      <div className="p-5">
        <div className="flex items-center gap-3">
          <span className="grid h-10 w-10 place-items-center rounded-xl bg-[#e7f1eb] text-[#36766d]"><Cloud size={20} /></span>
          <div><p className="text-[14px] font-semibold">MaxOS 0.4.5</p><p className="text-[10px] text-[#819698]">Installed on this device</p></div>
        </div>
        <div className="mt-5 rounded-xl border border-[#e3e9df] bg-[#f5f8f1] p-3">
          <p className="text-[10px] font-semibold text-[#566c56]">GitHub release feed</p>
          <p className="mt-1 text-[9px] leading-4 text-[#809080]">No published release was found. Check again after a MaxOS release is published.</p>
        </div>
        <button className="mt-4 rounded-lg bg-[#257d7e] px-3 py-2 text-[10px] font-semibold text-white">Check for updates</button>
      </div>
    </section>
  );

  if (app === "Settings") return (
    <section style={windowStyle} onPointerDown={onFocus} className="absolute right-5 top-[74px] z-40 flex h-[420px] w-[360px] flex-col overflow-hidden rounded-xl border border-white/90 bg-[#f8fbfa] text-[#233b42] shadow-[0_24px_70px_rgba(14,48,52,.30)] ring-1 ring-[#174e56]/15">
      {commonHeader}
      <div className="flex min-h-0 flex-1">
        <nav className="w-[112px] shrink-0 border-r border-[#dce6e4] bg-[#edf4f2] p-2">
          <p className="px-2 pb-2 pt-1 text-[9px] font-bold uppercase tracking-[.16em] text-[#7a9697]">System</p>
          {["Display", "Accounts", "Network", "Storage"].map((item, i) => <div key={item} className={`mb-1 flex items-center gap-2 rounded-lg px-2 py-2 text-[11px] ${i === 0 ? "bg-white font-semibold text-[#176b7a] shadow-sm" : "text-[#60787d]"}`}><Monitor size={13} />{item}</div>)}
        </nav>
        <div className="flex-1 overflow-auto p-4">
          <div className="flex items-start justify-between">
            <div><p className="text-[16px] font-semibold">Appearance</p><p className="mt-1 text-[10px] text-[#758c90]">Shared with your MaxNet account</p></div>
            <Palette size={17} className="text-[#25817f]" />
          </div>
          <label className="mt-5 block text-[10px] font-semibold text-[#597277]" htmlFor="maxos-theme">Desktop theme</label>
          <select id="maxos-theme" className="mt-1.5 w-full rounded-lg border border-[#cbdad8] bg-white px-3 py-2 text-[11px] text-[#28454a] shadow-sm outline-none focus:border-[#25817f]" defaultValue="vista">
            {themes.map(([id, label]) => <option value={id} key={id}>{label}</option>)}
          </select>
          <div className="mt-4 rounded-lg border border-[#cfdfdb] bg-[#eaf5f1] p-3">
            <div className="flex items-center gap-2 text-[11px] font-semibold text-[#29675e]"><Check size={14} /> Windows Vista active</div>
            <p className="mt-1 text-[10px] leading-4 text-[#64817b]">This preference follows max_user between the MaxNet site and MaxOS.</p>
          </div>
          <div className="mt-4 border-t border-[#e1e9e7] pt-3">
            <p className="text-[10px] font-semibold">This device</p>
            <p className="mt-1 text-[10px] leading-4 text-[#71878a]">Display and accessibility choices stay local to this computer.</p>
          </div>
        </div>
      </div>
    </section>
  );

  if (app === "Chatbox") return (
    <section style={windowStyle} onPointerDown={onFocus} className="absolute left-[24%] top-[13%] z-20 flex h-[336px] w-[382px] flex-col overflow-hidden rounded-xl border border-white/90 bg-[#f9fcfb] text-[#263e43] shadow-[0_22px_65px_rgba(11,49,53,.28)] ring-1 ring-[#174e56]/15">
      {commonHeader}
      <div className="flex items-center justify-between border-b border-[#e1e9e7] px-4 py-2">
        <div><p className="text-[11px] font-semibold">MaxNet Chatroom</p><p className="text-[9px] text-[#84999a]">Lobby · 12 people online</p></div>
        <span className="rounded-full bg-[#e3f4e9] px-2 py-1 text-[9px] font-semibold text-[#31734e]">Connected</span>
      </div>
      <div className="flex-1 space-y-3 overflow-hidden px-4 py-3 text-[11px]">
        <div className="flex gap-2"><span className="grid h-6 w-6 shrink-0 place-items-center rounded-full bg-[#e3d8c5] text-[9px] font-bold text-[#71563c]">m</span><div><b className="text-[#357e77]">maple</b><span className="ml-2 text-[9px] text-[#a0b0b0]">12:38</span><p className="mt-0.5">anyone on the Network today?</p></div></div>
        <div className="flex gap-2"><span className="grid h-6 w-6 shrink-0 place-items-center rounded-full bg-[#d2e1ea] text-[9px] font-bold text-[#456b80]">r</span><div><b className="text-[#55768a]">river</b><span className="ml-2 text-[9px] text-[#a0b0b0]">12:39</span><p className="mt-0.5">Just posted the weekend build notes.</p></div></div>
        <div className="flex gap-2"><span className="grid h-6 w-6 shrink-0 place-items-center rounded-full bg-[#ead8dc] text-[9px] font-bold text-[#81545f]">m</span><div><b className="text-[#986174]">max_user</b><span className="ml-2 text-[9px] text-[#a0b0b0]">12:40</span><p className="mt-0.5">I’ll check them after this session.</p></div></div>
      </div>
      <div className="flex gap-2 border-t border-[#e1e9e7] bg-[#f4f8f7] p-3"><input readOnly value="Message the room…" className="min-w-0 flex-1 rounded-lg border border-[#d6e1df] bg-white px-3 py-2 text-[10px] text-[#9baaaa]" /><button className="rounded-lg bg-[#257d7e] px-3 text-[10px] font-semibold text-white">Send</button></div>
    </section>
  );

  if (app === "the Network") return (
    <section style={windowStyle} onPointerDown={onFocus} className="absolute right-[5%] top-[15%] z-20 flex h-[418px] w-[390px] flex-col overflow-hidden rounded-xl border border-white/90 bg-[#f9fcfb] text-[#263e43] shadow-[0_22px_65px_rgba(11,49,53,.28)] ring-1 ring-[#174e56]/15">
      {commonHeader}
      <div className="flex items-center gap-2 border-b border-[#e1e9e7] px-4 py-3"><div className="grid h-8 w-8 place-items-center rounded-lg bg-[#267d72] text-white"><Globe2 size={16} /></div><div><p className="text-[12px] font-semibold">the Network</p><p className="text-[9px] text-[#819698]">Posts from your community</p></div><button className="ml-auto rounded-lg bg-[#e8f3f0] px-2.5 py-1.5 text-[9px] font-semibold text-[#34786e]">For you</button></div>
      <div className="flex-1 overflow-hidden p-3">
        <article className="rounded-xl border border-[#e0e9e7] bg-white p-3 shadow-[0_2px_7px_rgba(35,67,74,.04)]">
          <div className="flex items-center gap-2"><span className="grid h-7 w-7 place-items-center rounded-full bg-[#e8d7ca] text-[10px] font-bold text-[#775d4d]">m</span><div><p className="text-[10px] font-semibold">maple</p><p className="text-[9px] text-[#91a2a3]">8 min ago</p></div><span className="ml-auto text-[9px] text-[#8ca1a0]">Community post</span></div>
          <p className="mt-3 text-[11px] leading-[1.55]">New MaxNet setup is looking good. What apps should we add next?</p>
          <div className="mt-3 rounded-lg bg-[#eaf3ef] px-3 py-2 text-[9px] text-[#52756c]">#desktop-builds　#maxnet</div>
          <div className="mt-3 flex items-center gap-4 border-t border-[#edf1ef] pt-2 text-[9px] text-[#78908f]"><span className="flex items-center gap-1"><Heart size={12} />8</span><span>Reply · 3</span><span>Repost</span></div>
        </article>
        <article className="mt-2 rounded-xl border border-[#e0e9e7] bg-white p-3">
          <div className="flex items-center gap-2"><span className="grid h-7 w-7 place-items-center rounded-full bg-[#d6e7df] text-[10px] font-bold text-[#426b57]">j</span><div><p className="text-[10px] font-semibold">juniper</p><p className="text-[9px] text-[#91a2a3]">24 min ago</p></div></div>
          <p className="mt-2 text-[10px] leading-[1.5]">Planner finally has my whole week in one place. The quiet reminders are just right.</p>
        </article>
      </div>
      <div className="border-t border-[#e1e9e7] px-3 py-2 text-[9px] text-[#7f9798]">Your feed is ready when you are.</div>
    </section>
  );

  if (app === "Eaglercraft") return (
    <section style={windowStyle} onPointerDown={onFocus} className="absolute bottom-[72px] left-[37%] z-20 flex h-[235px] w-[360px] flex-col overflow-hidden rounded-xl border border-white/80 bg-[#f9fcfb] text-[#263e43] shadow-[0_22px_65px_rgba(11,49,53,.30)] ring-1 ring-[#174e56]/15">
      {commonHeader}
      <div className="relative flex flex-1 flex-col items-center justify-center overflow-hidden bg-[#152f32] text-center text-white">
        <div className="absolute inset-0 opacity-50" style={{ background: "radial-gradient(ellipse at 50% 120%, #7ca67b 0, transparent 55%), linear-gradient(150deg, #18383a, #182c38 60%, #273c31)" }} />
        <div className="relative"><p className="font-mono text-[22px] font-black tracking-[.22em] text-[#a7d7bb]">EAGLERCRAFT</p><p className="mt-1 text-[9px] tracking-wide text-white/65">A world away, one click from MaxNet</p><button className="mt-4 rounded-lg bg-[#4f957a] px-5 py-2 text-[10px] font-semibold text-white shadow-md">Join server</button></div>
        <div className="absolute bottom-2 right-3 text-[8px] text-white/45">Local session ready</div>
      </div>
    </section>
  );

  if (app === "Planner") return (
    <section style={windowStyle} onPointerDown={onFocus} className="absolute left-[19%] top-[25%] z-30 flex h-[340px] w-[380px] flex-col overflow-hidden rounded-xl border border-white/90 bg-[#f9fcfb] text-[#263e43] shadow-[0_22px_65px_rgba(11,49,53,.28)] ring-1 ring-[#174e56]/15">
      {commonHeader}
      <div className="p-4"><p className="text-[16px] font-semibold">This week</p><p className="text-[10px] text-[#819698]">A little structure, room to move.</p>
        {["Today · Finish map notes", "Wed · Open Forum meetup", "Fri · Eaglercraft build night"].map((item, i) => <div key={item} className="mt-3 flex items-center gap-3 rounded-lg border border-[#e3ebe9] bg-white px-3 py-2.5"><span className={`h-2 w-2 rounded-full ${i === 0 ? "bg-[#d68651]" : "bg-[#4b9a8a]"}`} /><span className="text-[10px]">{item}</span></div>)}
      </div>
    </section>
  );

  if (app === "Games Manager") return (
    <section style={windowStyle} onPointerDown={onFocus} className="absolute left-[31%] top-[24%] z-30 flex h-[320px] w-[380px] flex-col overflow-hidden rounded-xl border border-white/90 bg-[#f9fcfb] text-[#263e43] shadow-[0_22px_65px_rgba(11,49,53,.28)] ring-1 ring-[#174e56]/15">
      {commonHeader}
      <div className="p-4"><p className="text-[15px] font-semibold">Your game shelf</p><p className="mt-1 text-[10px] text-[#819698]">3 titles ready on this desktop</p>
        <div className="mt-4 grid grid-cols-3 gap-2">{["Eaglercraft", "Chess", "Geometry Dash"].map((name, i) => <button key={name} className="rounded-xl border border-[#dce8e5] bg-[#f5faf8] p-3 text-left hover:border-[#77aaa0]"><div className={`mb-3 grid h-12 place-items-center rounded-lg ${i === 0 ? "bg-[#dbeadf]" : i === 1 ? "bg-[#e7e5d8]" : "bg-[#e7d9d6]"}`}><Gamepad2 size={20} className="text-[#4c7e72]" /></div><span className="text-[9px] font-semibold">{name}</span></button>)}</div>
      </div>
    </section>
  );

  if (app === "Open Forum") return (
    <section style={windowStyle} onPointerDown={onFocus} className="absolute left-[25%] top-[18%] z-30 flex h-[365px] w-[390px] flex-col overflow-hidden rounded-xl border border-white/90 bg-[#f9fcfb] text-[#263e43] shadow-[0_22px_65px_rgba(11,49,53,.28)] ring-1 ring-[#174e56]/15">
      {commonHeader}
      <div className="p-4"><div className="flex items-center justify-between"><div><p className="text-[15px] font-semibold">Open Forum</p><p className="text-[10px] text-[#819698]">The slower side of the conversation</p></div><button className="rounded-lg bg-[#257d7e] px-3 py-2 text-[9px] font-semibold text-white">New topic</button></div>
      {["Show us your desktop setup", "What are you playing this week?", "Planner tips that actually stick"].map((item, i) => <div key={item} className="mt-3 flex items-center justify-between rounded-lg border border-[#e1e9e7] bg-white p-3"><div><p className="text-[10px] font-semibold">{item}</p><p className="mt-1 text-[9px] text-[#8ba0a0]">{["maple · 14 replies", "river · 8 replies", "juniper · 5 replies"][i]}</p></div><ChevronRight size={14} className="text-[#8ca3a0]" /></div>)}</div>
    </section>
  );

  return (
    <section style={windowStyle} onPointerDown={onFocus} className="absolute left-[30%] top-[20%] z-30 flex h-[310px] w-[350px] flex-col overflow-hidden rounded-xl border border-white/90 bg-[#f9fcfb] text-[#263e43] shadow-[0_22px_65px_rgba(11,49,53,.28)] ring-1 ring-[#174e56]/15">
      {commonHeader}
      <div className="flex items-center gap-2 p-4"><Folder size={20} className="text-[#568879]" /><div><p className="text-[12px] font-semibold">On this computer</p><p className="text-[9px] text-[#829697]">Files stay available offline</p></div></div>
      <div className="mx-4 rounded-lg border border-[#dfe9e6] bg-white p-3 text-[10px]">Desktop <span className="float-right text-[#8ba09e]">4 items</span><div className="mt-2 border-t border-[#edf1ef] pt-2">MaxNet notes <span className="float-right text-[#8ba09e]">Saved here</span></div><div className="mt-2">Screenshots <span className="float-right text-[#8ba09e]">2 files</span></div></div>
    </section>
  );
}

export function MaxOSExtended() {
  const [launcherOpen, setLauncherOpen] = useState(true);
  const [activeApps, setActiveApps] = useState<AppId[]>(["Chatbox", "the Network", "Eaglercraft"]);
  const [activeApp, setActiveApp] = useState<AppId>("Chatbox");
  const [search, setSearch] = useState("");
  const [menuSection, setMenuSection] = useState<"MaxNet" | "System">("MaxNet");
  const [showQuickSettings, setShowQuickSettings] = useState(false);
  const [minimizedApps, setMinimizedApps] = useState<AppId[]>([]);
  const [maximizedApp, setMaximizedApp] = useState<AppId | null>(null);

  const openApp = (app: AppId) => {
    setActiveApps((current) => current.includes(app) ? current : [...current, app]);
    setMinimizedApps((current) => current.filter((item) => item !== app));
    setActiveApp(app);
    setLauncherOpen(false);
  };
  const closeApp = (app: AppId) => {
    setActiveApps((current) => current.filter((item) => item !== app));
    setMinimizedApps((current) => current.filter((item) => item !== app));
    if (maximizedApp === app) setMaximizedApp(null);
    if (activeApp === app) setActiveApp("Chatbox");
  };

  return (
    <main className="relative h-[820px] min-h-[620px] w-full min-w-[900px] overflow-hidden bg-[#174d58] font-['Trebuchet_MS',sans-serif] text-[#f7fbf8]">
      <div className="absolute inset-0" style={{ background: "radial-gradient(ellipse at 73% 12%, rgba(201,224,189,.58), transparent 26%), radial-gradient(ellipse at 24% 86%, rgba(213,145,94,.30), transparent 35%), linear-gradient(132deg, #174c57 0%, #216d72 44%, #387d77 72%, #316b67 100%)" }} />
      <div className="pointer-events-none absolute -right-24 top-[90px] h-[530px] w-[530px] rounded-full border border-white/10 bg-[radial-gradient(circle_at_35%_28%,rgba(235,244,218,.20),rgba(159,203,181,.07)_42%,rgba(16,60,68,.18)_73%)] shadow-[inset_22px_28px_70px_rgba(255,255,255,.08),0_30px_100px_rgba(11,47,51,.18)]" />
      <div className="pointer-events-none absolute right-[15%] top-[16%] h-[360px] w-[360px] rotate-[-22deg] rounded-[42%] border border-white/10 bg-[linear-gradient(145deg,rgba(229,239,216,.13),rgba(35,110,111,.03)_62%,rgba(222,145,99,.08))]" />
      <div className="pointer-events-none absolute inset-0 bg-[linear-gradient(90deg,rgba(5,35,42,.18),transparent_46%,rgba(5,39,46,.06))]" />

      <header className="absolute left-0 right-0 top-0 z-10 flex h-9 items-center justify-between border-b border-white/20 bg-[#153f49]/45 px-4 text-[10px] shadow-[0_1px_8px_rgba(8,41,45,.12)] backdrop-blur-xl">
        <div className="flex items-center gap-5"><div className="flex items-center gap-2 font-bold tracking-wide"><span className="grid h-5 w-5 place-items-center rounded-md bg-[#d9e8c9] text-[10px] font-black text-[#246d70]">M</span>MaxOS</div><span className="text-white/65">File</span><span className="text-white/65">Edit</span><span className="text-white/65">View</span></div>
        <div className="flex items-center gap-3 text-white/80"><span className="flex items-center gap-1.5"><WifiOff size={12} /> Site offline</span><span className="h-3 w-px bg-white/25" /><span>Local tools ready</span></div>
      </header>

      <aside className="absolute left-5 top-[66px] z-10 flex w-[84px] flex-col gap-4">
        <button onDoubleClick={() => openApp("Files")} onClick={() => openApp("Files")} className="group flex flex-col items-center gap-1.5 rounded-xl px-2 py-2 text-center text-[10px] text-white drop-shadow hover:bg-white/10">
          <span className="grid h-11 w-11 place-items-center rounded-[14px] border border-white/45 bg-[linear-gradient(145deg,rgba(240,247,224,.86),rgba(83,152,139,.68))] text-[#1e6265] shadow-[0_5px_14px_rgba(7,44,49,.20)]"><Laptop size={22} /></span>Computer
        </button>
        <button onClick={() => openApp("Files")} className="group flex flex-col items-center gap-1.5 rounded-xl px-2 py-2 text-center text-[10px] text-white drop-shadow hover:bg-white/10">
          <span className="grid h-11 w-11 place-items-center rounded-[14px] border border-white/45 bg-[linear-gradient(145deg,rgba(230,239,225,.88),rgba(132,183,152,.72))] text-[#276c64] shadow-[0_5px_14px_rgba(7,44,49,.20)]"><Folder size={22} /></span>Files
        </button>
        <button onClick={() => openApp("Settings")} className="group flex flex-col items-center gap-1.5 rounded-xl px-2 py-2 text-center text-[10px] text-white drop-shadow hover:bg-white/10">
          <span className="grid h-11 w-11 place-items-center rounded-[14px] border border-white/45 bg-[linear-gradient(145deg,rgba(245,228,208,.9),rgba(204,158,123,.72))] text-[#79533f] shadow-[0_5px_14px_rgba(7,44,49,.20)]"><Settings size={21} /></span>Settings
        </button>
      </aside>

      <div className="absolute left-[118px] top-[55px] z-10 flex items-center gap-2 rounded-full border border-white/20 bg-[#eaf4e9]/15 px-3 py-1.5 text-[9px] text-white/90 shadow-sm backdrop-blur-md">
        <span className="h-1.5 w-1.5 rounded-full bg-[#c9e5a5]" /> Offline-ready · Your desktop stays yours
      </div>

      {activeApps.map((app) => <AppWindow key={app} app={app} active={activeApp === app} minimized={minimizedApps.includes(app)} maximized={maximizedApp === app} onFocus={() => setActiveApp(app)} onClose={() => closeApp(app)} onMinimize={() => setMinimizedApps((current) => current.includes(app) ? current : [...current, app])} onToggleMaximize={() => setMaximizedApp((current) => current === app ? null : app)} />)}

      <div className="absolute bottom-0 left-0 right-0 z-50 flex h-[52px] items-center gap-2 border-t border-white/60 bg-[linear-gradient(180deg,rgba(244,249,245,.84),rgba(218,232,229,.88))] px-2 text-[#31545a] shadow-[0_-7px_28px_rgba(8,42,46,.20)] backdrop-blur-2xl">
        <button onClick={() => setLauncherOpen((open) => !open)} aria-label="Open MaxOS Start menu" className={`flex h-10 shrink-0 items-center gap-2 rounded-xl border border-white/80 bg-[linear-gradient(145deg,#f2f7e8,#d5e8dc)] px-3 text-[#315c5a] shadow-[0_2px_6px_rgba(29,74,69,.24)] transition-transform hover:scale-[1.02] ${launcherOpen ? "ring-2 ring-[#5d9f90]/50" : ""}`}>
          <span className="h-6 w-6 rounded-md bg-gradient-to-br from-blue-600 to-green-500 shadow-inner" />
          <span className="text-[10px] font-bold">Start</span>
        </button>
        <div className="h-7 w-px bg-[#a9bfbb]" />
        <div className="flex items-center gap-1">
          {activeApps.filter((app) => app !== "Settings" && app !== "Files").map((app) => {
            const Icon = appCatalog.find((item) => item.name === app)?.icon || Settings;
            return <button key={app} onClick={() => { setMinimizedApps((current) => current.filter((item) => item !== app)); setActiveApp(app); }} className={`relative flex h-9 items-center gap-2 rounded-lg px-2.5 text-[10px] ${activeApp === app && !minimizedApps.includes(app) ? "bg-white/85 shadow-sm" : "hover:bg-white/55"}`}><Icon size={15} className="text-[#367d78]" /><span className="max-w-[90px] truncate">{app}</span>{activeApp === app && !minimizedApps.includes(app) && <i className="absolute bottom-0 left-1/2 h-[2px] w-5 -translate-x-1/2 rounded-full bg-[#318779]" />}</button>;
          })}
          {activeApps.filter((app) => app === "Settings" || app === "Files").map((app) => <button key={app} onClick={() => setActiveApp(app)} className="rounded-lg px-2 py-2 text-[10px] hover:bg-white/55">{app}</button>)}
        </div>
        <div className="flex-1" />
        <button onClick={() => setShowQuickSettings((value) => !value)} className="flex items-center gap-2 rounded-lg px-2 py-1.5 hover:bg-white/60"><Wifi size={14} /><BatteryFull size={15} /></button>
        <button onClick={() => setShowQuickSettings((value) => !value)} className="min-w-[76px] rounded-lg px-2 py-1 text-right leading-tight hover:bg-white/60"><span className="block text-[11px] font-semibold">12:42 PM</span><span className="text-[9px] text-[#718c8e]">Tuesday, October 27</span></button>
        <button onClick={() => setShowQuickSettings((value) => !value)} aria-label="Notifications" className="grid h-8 w-8 place-items-center rounded-lg hover:bg-white/60"><Bell size={15} /></button>
      </div>

      {launcherOpen && <section className="absolute bottom-[58px] left-2 z-[60] flex h-[535px] w-[440px] overflow-hidden rounded-2xl border border-white/80 bg-[#f1f7f4]/95 text-[#26484d] shadow-[0_26px_80px_rgba(5,36,42,.40)] ring-1 ring-[#1c5158]/20 backdrop-blur-xl">
        <div className="flex w-[128px] shrink-0 flex-col border-r border-[#d4e3de] bg-[#e6f0eb]/90 p-3">
          <div className="mb-4 flex items-center gap-2 rounded-xl bg-white/75 p-2 shadow-sm"><span className="grid h-8 w-8 place-items-center rounded-full bg-[#d8e8d7] text-[11px] font-bold text-[#386b5e]">m</span><div className="min-w-0"><p className="truncate text-[10px] font-semibold">max_user</p><p className="text-[9px] text-[#819796]">Member</p></div></div>
          <p className="px-2 pb-1 text-[8px] font-bold uppercase tracking-[.16em] text-[#7e9994]">Launch</p>
          <button onClick={() => setMenuSection("MaxNet")} className={`mb-1 flex items-center gap-2 rounded-lg px-2 py-2 text-left text-[10px] ${menuSection === "MaxNet" ? "bg-white font-semibold text-[#267770] shadow-sm" : "text-[#67817f] hover:bg-white/65"}`}><Globe2 size={14} />MaxNet <ChevronRight size={12} className="ml-auto" /></button>
          <button onClick={() => setMenuSection("System")} className={`flex items-center gap-2 rounded-lg px-2 py-2 text-left text-[10px] ${menuSection === "System" ? "bg-white font-semibold text-[#267770] shadow-sm" : "text-[#67817f] hover:bg-white/65"}`}><HardDrive size={14} />System <ChevronRight size={12} className="ml-auto" /></button>
          <div className="mt-auto rounded-xl border border-[#d4e3de] bg-white/65 p-2.5">
            <div className="flex items-center gap-1.5 text-[9px] font-semibold text-[#36766d]"><ShieldCheck size={13} />Local device</div>
            <p className="mt-1 text-[9px] leading-4 text-[#7b9290]">Administrator</p>
            <p className="mt-2 border-t border-[#e0e9e5] pt-2 text-[8px] leading-3.5 text-[#91a3a1]">Separate from your MaxNet Member rank.</p>
          </div>
        </div>
        <div className="flex min-w-0 flex-1 flex-col p-4">
          <div className="flex items-center justify-between"><div><p className="text-[15px] font-semibold">{menuSection}</p><p className="mt-0.5 text-[9px] text-[#849a99]">{menuSection === "MaxNet" ? "Your community, on this desktop" : "Tools that live on this computer"}</p></div><button className="rounded-md p-1.5 text-[#829794] hover:bg-white" onClick={() => setLauncherOpen(false)} aria-label="Close launcher"><X size={14} /></button></div>
          <label className="mt-3 flex h-8 items-center gap-2 rounded-lg border border-[#d9e5e1] bg-white/85 px-2.5"><Search size={13} className="text-[#8aa09d]" /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search apps and files" className="min-w-0 flex-1 bg-transparent text-[10px] outline-none placeholder:text-[#9aabaa]" /></label>
          {menuSection === "MaxNet" ? <>
            <p className="mb-2 mt-4 text-[8px] font-bold uppercase tracking-[.15em] text-[#8ba09c]">MaxNet apps</p>
            <div className="grid grid-cols-2 gap-2">
              {appCatalog.filter((app) => app.name.toLowerCase().includes(search.toLowerCase())).map((app) => { const Icon = app.icon; return <button key={app.name} onClick={() => openApp(app.name)} className="flex items-center gap-2 rounded-xl border border-[#dfe9e5] bg-white/90 p-2 text-left shadow-[0_2px_5px_rgba(30,67,64,.04)] transition hover:-translate-y-0.5 hover:border-[#91bdb1] hover:shadow-md"><span className={`grid h-8 w-8 shrink-0 place-items-center rounded-[10px] text-white ${app.color}`}><Icon size={16} /></span><span className="min-w-0"><span className="block truncate text-[10px] font-semibold">{app.name}</span><span className="block truncate text-[8px] text-[#8a9d9d]">{app.detail}</span></span></button>; })}
            </div>
            <div className="mt-auto flex items-center justify-between rounded-xl border border-[#dce8e2] bg-[#e7f1eb] px-3 py-2">
              <div className="flex items-center gap-2"><span className="grid h-7 w-7 place-items-center rounded-full bg-[#d6e6d9] text-[9px] font-bold text-[#3d715f]">m</span><div><p className="text-[9px] font-semibold">max_user · Member</p><p className="text-[8px] text-[#78918c]">Shared MaxNet account</p></div></div><button onClick={() => openApp("Settings")} className="rounded-lg px-2 py-1.5 text-[8px] font-semibold text-[#39796f] hover:bg-white">Account & theme</button>
            </div>
          </> : <div className="mt-4 space-y-2">
            {[
              { label: "Files", icon: Folder, detail: "Local documents and downloads", target: "Files" as AppId },
              { label: "Settings", icon: Settings, detail: "Themes, accounts, devices", target: "Settings" as AppId },
              { label: "Computer", icon: Laptop, detail: "Storage and system details", target: "Computer" as AppId },
              { label: "Help", icon: Shield, detail: "MaxOS basics and accessibility", target: "Help" as AppId },
              { label: "Update Center", icon: Cloud, detail: "MaxOS release updates", target: "Update Center" as AppId },
            ].filter((item) => item.label.toLowerCase().includes(search.toLowerCase())).map(({ label, icon: Icon, detail, target }) => (
              <button key={label} onClick={() => openApp(target)} className="flex w-full items-center gap-3 rounded-xl border border-[#dfe9e5] bg-white/90 p-3 text-left hover:border-[#91bdb1]">
                <span className="text-[#47877c]"><Icon size={17} /></span>
                <span><b className="block text-[10px]">{label}</b><span className="text-[9px] text-[#8a9d9d]">{detail}</span></span>
                <ChevronRight size={13} className="ml-auto text-[#9aabaa]" />
              </button>
            ))}
            <div className="mt-3 rounded-xl border border-[#dce8e2] bg-[#e7f1eb] p-3 text-[9px] leading-4 text-[#718b86]">These tools are stored on this computer. MaxNet apps reconnect when the site is available.</div>
          </div>}
        </div>
      </section>}

      {showQuickSettings && <section className="absolute bottom-[60px] right-4 z-[70] w-[250px] rounded-2xl border border-white/80 bg-[#f5faf7]/95 p-4 text-[#31565b] shadow-[0_20px_60px_rgba(5,36,42,.32)] backdrop-blur-xl">
        <div className="flex items-center justify-between"><p className="text-[12px] font-semibold">Quick settings</p><button onClick={() => setShowQuickSettings(false)}><X size={14} /></button></div>
        <div className="mt-3 grid grid-cols-2 gap-2"><div className="rounded-xl bg-[#dceee6] p-3 text-[9px]"><WifiOff size={15} className="mb-2 text-[#478477]" />Site offline</div><div className="rounded-xl bg-[#e9f0e6] p-3 text-[9px]"><BatteryFull size={15} className="mb-2 text-[#6d9366]" />Battery 84%</div></div>
        <p className="mt-3 text-[9px] leading-4 text-[#7b9290]">Local apps and files keep working. MaxNet community features will reconnect when service returns.</p>
      </section>}

      <div className="pointer-events-none absolute bottom-[62px] right-5 z-10 hidden rounded-xl border border-white/20 bg-[#153f49]/30 px-3 py-2 text-[9px] text-white/75 shadow-sm backdrop-blur-md xl:block">
        <div className="flex items-center gap-1.5"><Cloud size={12} /> max_user</div>
        <div className="mt-1">Account and theme travel together</div>
      </div>
    </main>
  );
}
