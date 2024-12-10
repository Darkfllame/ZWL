const std = @import("std");
const builtin = @import("builtin");

pub const CALLBACK: std.builtin.CallingConvention = if (builtin.cpu.arch == .x86) .Stdcall else .C;
pub const WINAPI: std.builtin.CallingConvention = if (builtin.cpu.arch == .x86) .Stdcall else .C;
pub const WINAPIV: std.builtin.CallingConvention = .C;
pub const APIENTRY: std.builtin.CallingConvention = WINAPI;
pub const APIPRIVATE: std.builtin.CallingConvention = if (builtin.cpu.arch == .x86) .Stdcall else .C;
pub const PASCAL: std.builtin.CallingConvention = if (builtin.cpu.arch == .x86) .Stdcall else .C;

pub const BOOL = i32;
pub const BYTE = u8;
pub const WORD = i16;
pub const SHORT = u16;
pub const ATOM = WORD;
pub const DWORD = i32;
pub const INT = i32;
pub const UINT = u32;
pub const INT_PTR = u64;
pub const LONG = i32;
pub const ULONG = i32;
pub const LONG_PTR = i64;
pub const ULONG_PTR = u64;
pub const LRESULT = LONG_PTR;
pub const LPARAM = LONG_PTR;
pub const WPARAM = INT_PTR;
pub const LPVOID = *anyopaque;
pub const LPCWSTR = [*:0]align(1) const u16;
pub const LPWSTR = [*:0]u16;
pub const HANDLE = *anyopaque;
pub const HINSTANCE = *opaque {};
pub const HMODULE = *opaque {};
pub const HWND = *opaque {};
pub const HICON = *opaque {};
pub const HBRUSH = *opaque {};
pub const HCURSOR = *opaque {};
pub const HDC = *opaque {};
pub const HGLRC = *opaque {};
pub const WNDPROC = *const fn (hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) callconv(CALLBACK) LRESULT;
pub const PFTASKDIALOGCALLBACK = *const fn (hWnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM, lprefData: LONG_PTR) callconv(CALLBACK) HRESULT;

pub const FALSE: BOOL = 0;
pub const TRUE: BOOL = 1;

pub const HWND_NOTOPMOST: HWND = @ptrFromInt(@as(usize, @truncate(-2)));
pub const HWND_TOPMOSt: HWND = @ptrFromInt(@as(usize, @truncate(-1)));
pub const HWND_TOP: ?HWND = @ptrFromInt(0);
pub const HWND_BOTTOM: HWND = @ptrFromInt(1);
pub const HWND_BROADCAST: HWND = @ptrFromInt(0xFFFF);

pub const SWP_NOSIZE: UINT = 0x0001;
pub const SWP_NOMOVE: UINT = 0x0002;
pub const SWP_NOZORDER: UINT = 0x0004;
pub const SWP_NOREDRAW: UINT = 0x0008;
pub const SWP_NOACTIVATE: UINT = 0x0010;
pub const SWP_FRAMECHANGED: UINT = 0x0020;
pub const SWP_SHOWWINDOW: UINT = 0x0040;
pub const SWP_HIDEWINDOW: UINT = 0x0080;
pub const SWP_NOCOPYBITS: UINT = 0x0100;
pub const SWP_NOOWNERZORDER: UINT = 0x0200;
pub const SWP_NOSENDCHANGING: UINT = 0x0400;
pub const SWP_DRAWFRAME: UINT = SWP_FRAMECHANGED;
pub const SWP_NOREPOSITION: UINT = SWP_NOOWNERZORDER;
pub const SWP_DEFERERASE: UINT = 0x2000;
pub const SWP_ASYNCWINDOWPOS: UINT = 0x4000;

pub const CW_USEDEFAULT: i32 = @truncate(0x80000000);

pub const WS_OVERLAPPED: DWORD = 0x00000000;
pub const WS_TILED: DWORD = 0x00000000;
pub const WS_MAXIMIZEBOX: DWORD = 0x00010000;
pub const WS_TABSTOP: DWORD = 0x00010000;
pub const WS_GROUP: DWORD = 0x00020000;
pub const WS_MINIMIZEBOX: DWORD = 0x00020000;
pub const WS_THICKFRAME: DWORD = 0x00040000;
pub const WS_SYSMENU: DWORD = 0x00080000;
pub const WS_HSCROLL: DWORD = 0x00100000;
pub const WS_VSCROLL: DWORD = 0x00200000;
pub const WS_DLGFRAME: DWORD = 0x00400000;
pub const WS_BORDER: DWORD = 0x00800000;
pub const WS_CAPTION: DWORD = WS_BORDER | 0x00400000;
pub const WS_MAXIMIZE: DWORD = 0x01000000;
pub const WS_CLIPCHILDREN: DWORD = 0x02000000;
pub const WS_CLIPSIBLINGS: DWORD = 0x04000000;
pub const WS_DISABLED: DWORD = 0x08000000;
pub const WS_VISIBLE: DWORD = 0x10000000;
pub const WS_ICONIC: DWORD = 0x20000000;
pub const WS_MINIMIZE: DWORD = 0x20000000;
pub const WS_CHILD: DWORD = 0x40000000;
pub const WS_CHILDWINDOW: DWORD = 0x40000000;
pub const WS_POPUP: DWORD = @truncate(0x80000000);
pub const WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX);
pub const WS_POPUPWINDOW = (WS_POPUP | WS_BORDER | WS_SYSMENU);
pub const WS_TILEDWINDOW = (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX);

pub const WS_EX_LEFT: DWORD = 0x00000000;
pub const WS_EX_RIGHTSCROLLBAR: DWORD = 0x00000000;
pub const WS_EX_LTRREADING: DWORD = 0x00000000;
pub const WS_EX_DLGMODALFRAME: DWORD = 0x00000001;
pub const WS_EX_NOPARENTNOTIFY: DWORD = 0x00000004;
pub const WS_EX_TOPMOST: DWORD = 0x00000008;
pub const WS_EX_ACCEPTFILES: DWORD = 0x00000010;
pub const WS_EX_TRANSPARENT: DWORD = 0x00000020;
pub const WS_EX_MDICHILD: DWORD = 0x00000040;
pub const WS_EX_TOOLWINDOW: DWORD = 0x00000080;
pub const WS_EX_WINDOWEDGE: DWORD = 0x00000100;
pub const WS_EX_CLIENTEDGE: DWORD = 0x00000200;
pub const WS_EX_CONTEXTHELP: DWORD = 0x00000400;
pub const WS_EX_RIGHT: DWORD = 0x00001000;
pub const WS_EX_RTLREADING: DWORD = 0x00002000;
pub const WS_EX_LEFTSCROLLBAR: DWORD = 0x00004000;
pub const WS_EX_CONTROLPARENT: DWORD = 0x00010000;
pub const WS_EX_STATICEDGE: DWORD = 0x00020000;
pub const WS_EX_APPWINDOW: DWORD = 0x00040000;
pub const WS_EX_LAYERED: DWORD = 0x00080000;
pub const WS_EX_NOINHERITLAYOUT: DWORD = 0x00100000;
pub const WS_EX_NOREDIRECTIONBITMAP: DWORD = 0x00200000;
pub const WS_EX_LAYOUTRTL: DWORD = 0x00400000;
pub const WS_EX_COMPOSITED: DWORD = 0x02000000;
pub const WS_EX_NOACTIVATE: DWORD = 0x08000000;
pub const WS_EX_OVERLAPPEDWINDOW: DWORD = (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE);
pub const WS_EX_PALETTEWINDOW: DWORD = (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST);

pub const CS_VREDRAW: UINT = 0x0001;
pub const CS_HREDRAW: UINT = 0x0002;
pub const CS_DBLCLKS: UINT = 0x0008;
pub const CS_OWNDC: UINT = 0x0020;
pub const CS_CLASSDC: UINT = 0x0040;
pub const CS_PARENTDC: UINT = 0x0080;
pub const CS_NOCLOSE: UINT = 0x0200;
pub const CS_SAVEBITS: UINT = 0x0800;
pub const CS_BYTEALIGNCLIENT: UINT = 0x1000;
pub const CS_BYTEALIGNWINDOW: UINT = 0x2000;
pub const CS_GLOBALCLASS: UINT = 0x4000;
pub const CS_IME: UINT = 0x00010000;
pub const CS_DROPSHADOW: UINT = 0x00020000;

pub inline fn MAKEINTRESOURCE(i: u16) LPCWSTR {
    return @ptrFromInt(i);
}

pub const TD_WARNING_ICON = MAKEINTRESOURCE(@truncate(-1));
pub const TD_ERROR_ICON = MAKEINTRESOURCE(@truncate(-2));
pub const TD_INFORMATION_ICON = MAKEINTRESOURCE(@truncate(-3));
pub const TD_SHIELD_ICON = MAKEINTRESOURCE(@truncate(-4));

pub const IDC_ARROW = MAKEINTRESOURCE(32512);
pub const IDC_IBEAM = MAKEINTRESOURCE(32513);
pub const IDC_WAIT = MAKEINTRESOURCE(32514);
pub const IDC_CROSS = MAKEINTRESOURCE(32515);
pub const IDC_UPARROW = MAKEINTRESOURCE(32516);
pub const IDC_SIZE = MAKEINTRESOURCE(32640);
pub const IDC_ICON = MAKEINTRESOURCE(32641);
pub const IDC_SIZENWSE = MAKEINTRESOURCE(32642);
pub const IDC_SIZENESW = MAKEINTRESOURCE(32643);
pub const IDC_SIZEWE = MAKEINTRESOURCE(32644);
pub const IDC_SIZENS = MAKEINTRESOURCE(32645);
pub const IDC_SIZEALL = MAKEINTRESOURCE(32646);
pub const IDC_NO = MAKEINTRESOURCE(32648);
pub const IDC_HAND = MAKEINTRESOURCE(32649);
pub const IDC_APPSTARTING = MAKEINTRESOURCE(32650);
pub const IDC_HELP = MAKEINTRESOURCE(32651);
pub const IDC_PIN = MAKEINTRESOURCE(32671);
pub const IDC_PERSON = MAKEINTRESOURCE(32672);

pub const PM_NOREMOVE: UINT = 0x0000;
pub const PM_REMOVE: UINT = 0x0001;
pub const PM_NOYIELD: UINT = 0x0002;

pub const WA_INACTIVE: UINT = 0;
pub const WA_ACTIVE: UINT = 1;
pub const WA_CLICKACTIVE: UINT = 2;

//#region Window message
pub const WM_NULL: UINT = 0x0000;
pub const WM_CREATE: UINT = 0x0001;
pub const WM_DESTROY: UINT = 0x0002;
pub const WM_MOVE: UINT = 0x0003;
pub const WM_SIZE: UINT = 0x0005;
pub const WM_ACTIVATE: UINT = 0x0006;
pub const WM_SETFOCUS: UINT = 0x0007;
pub const WM_KILLFOCUS: UINT = 0x0008;
pub const WM_ENABLE: UINT = 0x000A;
pub const WM_SETREDRAW: UINT = 0x000B;
pub const WM_SETTEXT: UINT = 0x000C;
pub const WM_GETTEXT: UINT = 0x000D;
pub const WM_GETTEXTLENGTH: UINT = 0x000E;
pub const WM_PAINT: UINT = 0x000F;
pub const WM_CLOSE: UINT = 0x0010;
pub const WM_QUERYENDSESSION: UINT = 0x0011;
pub const WM_QUERYOPEN: UINT = 0x0013;
pub const WM_ENDSESSION: UINT = 0x0016;
pub const WM_QUIT: UINT = 0x0012;
pub const WM_ERASEBKGND: UINT = 0x0014;
pub const WM_SYSCOLORCHANGE: UINT = 0x0015;
pub const WM_SHOWWINDOW: UINT = 0x0018;
pub const WM_WININICHANGE: UINT = 0x001A;
pub const WM_SETTINGCHANGE: UINT = WM_WININICHANGE;
pub const WM_DEVMODECHANGE: UINT = 0x001B;
pub const WM_ACTIVATEAPP: UINT = 0x001C;
pub const WM_FONTCHANGE: UINT = 0x001D;
pub const WM_TIMECHANGE: UINT = 0x001E;
pub const WM_CANCELMODE: UINT = 0x001F;
pub const WM_SETCURSOR: UINT = 0x0020;
pub const WM_MOUSEACTIVATE: UINT = 0x0021;
pub const WM_CHILDACTIVATE: UINT = 0x0022;
pub const WM_QUEUESYNC: UINT = 0x0023;
pub const WM_GETMINMAXINFO: UINT = 0x0024;
pub const WM_PAINTICON: UINT = 0x0026;
pub const WM_ICONERASEBKGND: UINT = 0x0027;
pub const WM_NEXTDLGCTL: UINT = 0x0028;
pub const WM_SPOOLERSTATUS: UINT = 0x002A;
pub const WM_DRAWITEM: UINT = 0x002B;
pub const WM_MEASUREITEM: UINT = 0x002C;
pub const WM_DELETEITEM: UINT = 0x002D;
pub const WM_VKEYTOITEM: UINT = 0x002E;
pub const WM_CHARTOITEM: UINT = 0x002F;
pub const WM_SETFONT: UINT = 0x0030;
pub const WM_GETFONT: UINT = 0x0031;
pub const WM_SETHOTKEY: UINT = 0x0032;
pub const WM_GETHOTKEY: UINT = 0x0033;
pub const WM_QUERYDRAGICON: UINT = 0x0037;
pub const WM_COMPAREITEM: UINT = 0x0039;
pub const WM_GETOBJECT: UINT = 0x003D;
pub const WM_COMPACTING: UINT = 0x0041;
pub const WM_COMMNOTIFY: UINT = 0x0044;
pub const WM_WINDOWPOSCHANGING: UINT = 0x0046;
pub const WM_WINDOWPOSCHANGED: UINT = 0x0047;
pub const WM_POWER: UINT = 0x0048;
pub const WM_COPYDATA: UINT = 0x004A;
pub const WM_CANCELJOURNAL: UINT = 0x004B;
pub const WM_NOTIFY: UINT = 0x004E;
pub const WM_INPUTLANGCHANGEREQUEST: UINT = 0x0050;
pub const WM_INPUTLANGCHANGE: UINT = 0x0051;
pub const WM_TCARD: UINT = 0x0052;
pub const WM_HELP: UINT = 0x0053;
pub const WM_USERCHANGED: UINT = 0x0054;
pub const WM_NOTIFYFORMAT: UINT = 0x0055;
pub const WM_CONTEXTMENU: UINT = 0x007B;
pub const WM_STYLECHANGING: UINT = 0x007C;
pub const WM_STYLECHANGED: UINT = 0x007D;
pub const WM_DISPLAYCHANGE: UINT = 0x007E;
pub const WM_GETICON: UINT = 0x007F;
pub const WM_SETICON: UINT = 0x0080;
pub const WM_NCCREATE: UINT = 0x0081;
pub const WM_NCDESTROY: UINT = 0x0082;
pub const WM_NCCALCSIZE: UINT = 0x0083;
pub const WM_NCHITTEST: UINT = 0x0084;
pub const WM_NCPAINT: UINT = 0x0085;
pub const WM_NCACTIVATE: UINT = 0x0086;
pub const WM_GETDLGCODE: UINT = 0x0087;
pub const WM_SYNCPAINT: UINT = 0x0088;
pub const WM_NCMOUSEMOVE: UINT = 0x00A0;
pub const WM_NCLBUTTONDOWN: UINT = 0x00A1;
pub const WM_NCLBUTTONUP: UINT = 0x00A2;
pub const WM_NCLBUTTONDBLCLK: UINT = 0x00A3;
pub const WM_NCRBUTTONDOWN: UINT = 0x00A4;
pub const WM_NCRBUTTONUP: UINT = 0x00A5;
pub const WM_NCRBUTTONDBLCLK: UINT = 0x00A6;
pub const WM_NCMBUTTONDOWN: UINT = 0x00A7;
pub const WM_NCMBUTTONUP: UINT = 0x00A8;
pub const WM_NCMBUTTONDBLCLK: UINT = 0x00A9;
pub const WM_NCXBUTTONDOWN: UINT = 0x00AB;
pub const WM_NCXBUTTONUP: UINT = 0x00AC;
pub const WM_NCXBUTTONDBLCLK: UINT = 0x00AD;
pub const WM_INPUT_DEVICE_CHANGE: UINT = 0x00FE;
pub const WM_INPUT: UINT = 0x00FF;
pub const WM_KEYFIRST: UINT = 0x0100;
pub const WM_KEYDOWN: UINT = 0x0100;
pub const WM_KEYUP: UINT = 0x0101;
pub const WM_CHAR: UINT = 0x0102;
pub const WM_DEADCHAR: UINT = 0x0103;
pub const WM_SYSKEYDOWN: UINT = 0x0104;
pub const WM_SYSKEYUP: UINT = 0x0105;
pub const WM_SYSCHAR: UINT = 0x0106;
pub const WM_SYSDEADCHAR: UINT = 0x0107;
pub const WM_UNICHAR: UINT = 0x0109;
pub const WM_KEYLAST: UINT = 0x0109;
pub const UNICODE_NOCHAR: UINT = 0xFFFF;
pub const WM_IME_STARTCOMPOSITION: UINT = 0x010D;
pub const WM_IME_ENDCOMPOSITION: UINT = 0x010E;
pub const WM_IME_COMPOSITION: UINT = 0x010F;
pub const WM_IME_KEYLAST: UINT = 0x010F;
pub const WM_INITDIALOG: UINT = 0x0110;
pub const WM_COMMAND: UINT = 0x0111;
pub const WM_SYSCOMMAND: UINT = 0x0112;
pub const WM_TIMER: UINT = 0x0113;
pub const WM_HSCROLL: UINT = 0x0114;
pub const WM_VSCROLL: UINT = 0x0115;
pub const WM_INITMENU: UINT = 0x0116;
pub const WM_INITMENUPOPUP: UINT = 0x0117;
pub const WM_GESTURE: UINT = 0x0119;
pub const WM_GESTURENOTIFY: UINT = 0x011A;
pub const WM_MENUSELECT: UINT = 0x011F;
pub const WM_MENUCHAR: UINT = 0x0120;
pub const WM_ENTERIDLE: UINT = 0x0121;
pub const WM_MENURBUTTONUP: UINT = 0x0122;
pub const WM_MENUDRAG: UINT = 0x0123;
pub const WM_MENUGETOBJECT: UINT = 0x0124;
pub const WM_UNINITMENUPOPUP: UINT = 0x0125;
pub const WM_MENUCOMMAND: UINT = 0x0126;
pub const WM_CHANGEUISTATE: UINT = 0x0127;
pub const WM_UPDATEUISTATE: UINT = 0x0128;
pub const WM_QUERYUISTATE: UINT = 0x0129;
pub const WM_CTLCOLORMSGBOX: UINT = 0x0132;
pub const WM_CTLCOLOREDIT: UINT = 0x0133;
pub const WM_CTLCOLORLISTBOX: UINT = 0x0134;
pub const WM_CTLCOLORBTN: UINT = 0x0135;
pub const WM_CTLCOLORDLG: UINT = 0x0136;
pub const WM_CTLCOLORSCROLLBAR: UINT = 0x0137;
pub const WM_CTLCOLORSTATIC: UINT = 0x0138;
pub const MN_GETHMENU: UINT = 0x01E1;
pub const WM_MOUSEMOVE: UINT = 0x0200;
pub const WM_LBUTTONDOWN: UINT = 0x0201;
pub const WM_LBUTTONUP: UINT = 0x0202;
pub const WM_LBUTTONDBLCLK: UINT = 0x0203;
pub const WM_RBUTTONDOWN: UINT = 0x0204;
pub const WM_RBUTTONUP: UINT = 0x0205;
pub const WM_RBUTTONDBLCLK: UINT = 0x0206;
pub const WM_MBUTTONDOWN: UINT = 0x0207;
pub const WM_MBUTTONUP: UINT = 0x0208;
pub const WM_MBUTTONDBLCLK: UINT = 0x0209;
pub const WM_MOUSEWHEEL: UINT = 0x020A;
pub const WM_XBUTTONDOWN: UINT = 0x020B;
pub const WM_XBUTTONUP: UINT = 0x020C;
pub const WM_XBUTTONDBLCLK: UINT = 0x020D;
pub const WM_MOUSEHWHEEL: UINT = 0x020E;
pub const WM_MOUSELAST: UINT = 0x020E;
pub const WM_PARENTNOTIFY: UINT = 0x0210;
pub const WM_ENTERMENULOOP: UINT = 0x0211;
pub const WM_EXITMENULOOP: UINT = 0x0212;
pub const WM_NEXTMENU: UINT = 0x0213;
pub const WM_SIZING: UINT = 0x0214;
pub const WM_CAPTURECHANGED: UINT = 0x0215;
pub const WM_MOVING: UINT = 0x0216;
pub const WM_POWERBROADCAST: UINT = 0x0218;
pub const WM_DEVICECHANGE: UINT = 0x0219;
pub const WM_MDICREATE: UINT = 0x0220;
pub const WM_MDIDESTROY: UINT = 0x0221;
pub const WM_MDIACTIVATE: UINT = 0x0222;
pub const WM_MDIRESTORE: UINT = 0x0223;
pub const WM_MDINEXT: UINT = 0x0224;
pub const WM_MDIMAXIMIZE: UINT = 0x0225;
pub const WM_MDITILE: UINT = 0x0226;
pub const WM_MDICASCADE: UINT = 0x0227;
pub const WM_MDIICONARRANGE: UINT = 0x0228;
pub const WM_MDIGETACTIVE: UINT = 0x0229;
pub const WM_MDISETMENU: UINT = 0x0230;
pub const WM_ENTERSIZEMOVE: UINT = 0x0231;
pub const WM_EXITSIZEMOVE: UINT = 0x0232;
pub const WM_DROPFILES: UINT = 0x0233;
pub const WM_MDIREFRESHMENU: UINT = 0x0234;
pub const WM_POINTERDEVICECHANGE: UINT = 0x238;
pub const WM_POINTERDEVICEINRANGE: UINT = 0x239;
pub const WM_POINTERDEVICEOUTOFRANGE: UINT = 0x23A;
pub const WM_TOUCH: UINT = 0x0240;
pub const WM_NCPOINTERUPDATE: UINT = 0x0241;
pub const WM_NCPOINTERDOWN: UINT = 0x0242;
pub const WM_NCPOINTERUP: UINT = 0x0243;
pub const WM_POINTERUPDATE: UINT = 0x0245;
pub const WM_POINTERDOWN: UINT = 0x0246;
pub const WM_POINTERUP: UINT = 0x0247;
pub const WM_POINTERENTER: UINT = 0x0249;
pub const WM_POINTERLEAVE: UINT = 0x024A;
pub const WM_POINTERACTIVATE: UINT = 0x024B;
pub const WM_POINTERCAPTURECHANGED: UINT = 0x024C;
pub const WM_TOUCHHITTESTING: UINT = 0x024D;
pub const WM_POINTERWHEEL: UINT = 0x024E;
pub const WM_POINTERHWHEEL: UINT = 0x024F;
pub const WM_POINTERROUTEDTO: UINT = 0x0251;
pub const WM_POINTERROUTEDAWAY: UINT = 0x0252;
pub const WM_POINTERROUTEDRELEASED: UINT = 0x0253;
pub const WM_IME_SETCONTEXT: UINT = 0x0281;
pub const WM_IME_NOTIFY: UINT = 0x0282;
pub const WM_IME_CONTROL: UINT = 0x0283;
pub const WM_IME_COMPOSITIONFULL: UINT = 0x0284;
pub const WM_IME_SELECT: UINT = 0x0285;
pub const WM_IME_CHAR: UINT = 0x0286;
pub const WM_IME_REQUEST: UINT = 0x0288;
pub const WM_IME_KEYDOWN: UINT = 0x0290;
pub const WM_IME_KEYUP: UINT = 0x0291;
pub const WM_MOUSEHOVER: UINT = 0x02A1;
pub const WM_MOUSELEAVE: UINT = 0x02A3;
pub const WM_NCMOUSEHOVER: UINT = 0x02A0;
pub const WM_NCMOUSELEAVE: UINT = 0x02A2;
pub const WM_WTSSESSION_CHANGE: UINT = 0x02B1;
pub const WM_TABLET_FIRST: UINT = 0x02c0;
pub const WM_TABLET_LAST: UINT = 0x02df;
pub const WM_DPICHANGED: UINT = 0x02E0;
pub const WM_DPICHANGED_BEFOREPARENT: UINT = 0x02E2;
pub const WM_DPICHANGED_AFTERPARENT: UINT = 0x02E3;
pub const WM_GETDPISCALEDSIZE: UINT = 0x02E4;
pub const WM_CUT: UINT = 0x0300;
pub const WM_COPY: UINT = 0x0301;
pub const WM_PASTE: UINT = 0x0302;
pub const WM_CLEAR: UINT = 0x0303;
pub const WM_UNDO: UINT = 0x0304;
pub const WM_RENDERFORMAT: UINT = 0x0305;
pub const WM_RENDERALLFORMATS: UINT = 0x0306;
pub const WM_DESTROYCLIPBOARD: UINT = 0x0307;
pub const WM_DRAWCLIPBOARD: UINT = 0x0308;
pub const WM_PAINTCLIPBOARD: UINT = 0x0309;
pub const WM_VSCROLLCLIPBOARD: UINT = 0x030A;
pub const WM_SIZECLIPBOARD: UINT = 0x030B;
pub const WM_ASKCBFORMATNAME: UINT = 0x030C;
pub const WM_CHANGECBCHAIN: UINT = 0x030D;
pub const WM_HSCROLLCLIPBOARD: UINT = 0x030E;
pub const WM_QUERYNEWPALETTE: UINT = 0x030F;
pub const WM_PALETTEISCHANGING: UINT = 0x0310;
pub const WM_PALETTECHANGED: UINT = 0x0311;
pub const WM_HOTKEY: UINT = 0x0312;
pub const WM_PRINT: UINT = 0x0317;
pub const WM_PRINTCLIENT: UINT = 0x0318;
pub const WM_APPCOMMAND: UINT = 0x0319;
pub const WM_THEMECHANGED: UINT = 0x031A;
pub const WM_CLIPBOARDUPDATE: UINT = 0x031D;
pub const WM_DWMCOMPOSITIONCHANGED: UINT = 0x031E;
pub const WM_DWMNCRENDERINGCHANGED: UINT = 0x031F;
pub const WM_DWMCOLORIZATIONCOLORCHANGED: UINT = 0x0320;
pub const WM_DWMWINDOWMAXIMIZEDCHANGE: UINT = 0x0321;
pub const WM_DWMSENDICONICTHUMBNAIL: UINT = 0x0323;
pub const WM_DWMSENDICONICLIVEPREVIEWBITMAP: UINT = 0x0326;
pub const WM_GETTITLEBARINFOEX: UINT = 0x033F;
pub const WM_HANDHELDFIRST: UINT = 0x0358;
pub const WM_HANDHELDLAST: UINT = 0x035F;
pub const WM_AFXFIRST: UINT = 0x0360;
pub const WM_AFXLAST: UINT = 0x037F;
pub const WM_PENWINFIRST: UINT = 0x0380;
pub const WM_PENWINLAST: UINT = 0x038F;
pub const WM_APP: UINT = 0x8000;
pub const WM_USER: UINT = 0x0400;
//#endregion

pub const TDN_CREATED: UINT = 0;
pub const TDN_NAVIGATED: UINT = 1;
pub const TDN_BUTTON_CLICKED: UINT = 2;
pub const TDN_HYPERLINK_CLICKED: UINT = 3;
pub const TDN_TIMER: UINT = 4;
pub const TDN_DESTROYED: UINT = 5;
pub const TDN_RADIO_BUTTON_CLICKED: UINT = 6;
pub const TDN_DIALOG_CONSTRUCTED: UINT = 7;
pub const TDN_VERIFICATION_CLICKED: UINT = 8;
pub const TDN_HELP: UINT = 9;
pub const TDN_EXPANDO_BUTTON_CLICKED: UINT = 10;

pub const IDOK: u32 = 1;
pub const IDCANCEL: u32 = 2;
pub const IDABORT: u32 = 3;
pub const IDRETRY: u32 = 4;
pub const IDIGNORE: u32 = 5;
pub const IDYES: u32 = 6;
pub const IDNO: u32 = 7;
pub const IDCLOSE: u32 = 8;
pub const IDHELP: u32 = 9;
pub const IDTRYAGAIN: u32 = 10;
pub const IDCONTINUE: u32 = 11;
pub const IDBUTTONINDEX0: u32 = 100;
pub const IDTIMEOUT: u32 = 32000;

pub const PFD_DRAW_TO_WINDOW: DWORD = 0x00000004;
pub const PFD_DRAW_TO_BITMAP: DWORD = 0x00000008;
pub const PFD_SUPPORT_GDI: DWORD = 0x00000010;
pub const PFD_SUPPORT_OPENGL: DWORD = 0x00000020;
pub const PFD_GENERIC_ACCELERATED: DWORD = 0x00001000;
pub const PFD_GENERIC_FORMAT: DWORD = 0x00000040;
pub const PFD_NEED_PALETTE: DWORD = 0x00000080;
pub const PFD_NEED_SYSTEM_PALETTE: DWORD = 0x00000100;
pub const PFD_DOUBLEBUFFER: DWORD = 0x00000001;
pub const PFD_STEREO: DWORD = 0x00000002;
pub const PFD_SWAP_LAYER_BUFFERS: DWORD = 0x00000800;
pub const PFD_DEPTH_DONTCARE: DWORD = 0x20000000;
pub const PFD_DOUBLEBUFFER_DONTCARE: DWORD = 0x40000000;
pub const PFD_STEREO_DONTCARE: DWORD = 0x80000000;
pub const PFD_SWAP_COPY: DWORD = 0x00000400;
pub const PFD_SWAP_EXCHANGE: DWORD = 0x00000200;
pub const PFD_TYPE_RGBA: BYTE = 0;
pub const PFD_TYPE_COLORINDEX: BYTE = 1;

pub const SW_HIDE: i32 = 0;
pub const SW_SHOWNORMAL: i32 = 1;
pub const SW_NORMAL: i32 = 1;
pub const SW_SHOWMINIMIZED: i32 = 2;
pub const SW_SHOWMAXIMIZED: i32 = 3;
pub const SW_MAXIMIZE: i32 = 3;
pub const SW_SHOWNOACTIVATE: i32 = 4;
pub const SW_SHOW: i32 = 5;
pub const SW_MINIMIZE: i32 = 6;
pub const SW_SHOWMINNOACTIVE: i32 = 7;
pub const SW_SHOWNA: i32 = 8;
pub const SW_RESTORE: i32 = 9;
pub const SW_SHOWDEFAULT: i32 = 0;
pub const SW_FORCEMINIMIZE: i32 = 1;

pub const WMSZ_BOTTOM: WPARAM = 6;
pub const WMSZ_BOTTOMLEFT: WPARAM = 7;
pub const WMSZ_BOTTOMRIGHT: WPARAM = 8;
pub const WMSZ_LEFT: WPARAM = 1;
pub const WMSZ_RIGHT: WPARAM = 2;
pub const WMSZ_TOP: WPARAM = 3;
pub const WMSZ_TOPLEFT: WPARAM = 4;
pub const WMSZ_TOPRIGHT: WPARAM = 5;

pub const HTBORDER: UINT = 18;
pub const HTBOTTOM: UINT = 15;
pub const HTBOTTOMLEFT: UINT = 16;
pub const HTBOTTOMRIGHT: UINT = 17;
pub const HTCAPTION: UINT = 2;
pub const HTCLIENT: UINT = 1;
pub const HTCLOSE: UINT = 20;
pub const HTERROR: UINT = -2;
pub const HTGROWBOX: UINT = 4;
pub const HTHELP: UINT = 21;
pub const HTHSCROLL: UINT = 6;
pub const HTLEFT: UINT = 10;
pub const HTMENU: UINT = 5;
pub const HTMAXBUTTON: UINT = 9;
pub const HTMINBUTTON: UINT = 8;
pub const HTNOWHERE: UINT = 0;
pub const HTREDUCE: UINT = 8;
pub const HTRIGHT: UINT = 11;
pub const HTSIZE: UINT = 4;
pub const HTSYSMENU: UINT = 3;
pub const HTTOP: UINT = 12;
pub const HTTOPLEFT: UINT = 13;
pub const HTTOPRIGHT: UINT = 14;
pub const HTTRANSPARENT: UINT = 0xFFFFFFFF;
pub const HTVSCROLL: UINT = 7;
pub const HTZOOM: UINT = 9;

pub const DBT_NO_DISK_SPACE: DWORD = 0x0047;
pub const DBT_LOW_DISK_SPACE: DWORD = 0x0048;
pub const DBT_CONFIGMGPRIVATE: DWORD = 0x7FFF;
pub const DBT_DEVICEARRIVAL: DWORD = 0x8000;
pub const DBT_DEVICEQUERYREMOVE: DWORD = 0x8001;
pub const DBT_DEVICEQUERYREMOVEFAILED: DWORD = 0x8002;
pub const DBT_DEVICEREMOVEPENDING: DWORD = 0x8003;
pub const DBT_DEVICEREMOVECOMPLETE: DWORD = 0x8004;
pub const DBT_DEVICETYPESPECIFIC: DWORD = 0x8005;
pub const DBT_CUSTOMEVENT: DWORD = 0x8006;
pub const DBT_DEVTYP_OEM: DWORD = 0x00000000;
pub const DBT_DEVTYP_DEVNODE: DWORD = 0x00000001;
pub const DBT_DEVTYP_VOLUME: DWORD = 0x00000002;
pub const DBT_DEVTYP_PORT: DWORD = 0x00000003;
pub const DBT_DEVTYP_NET: DWORD = 0x00000004;
pub const DBT_DEVTYP_DEVICEINTERFACE: DWORD = 0x00000005;
pub const DBT_DEVTYP_HANDLE: DWORD = 0x00000006;

pub const DEVICE_NOTIFY_WINDOW_HANDLE: DWORD = 0x00000000;
pub const DEVICE_NOTIFY_SERVICE_HANDLE: DWORD = 0x00000001;
pub const DEVICE_NOTIFY_ALL_INTERFACE_CLASSES: DWORD = 0x00000004;

pub const WGL_CONTEXT_MAJOR_VERSION_ARB: i32 = 0x2091;
pub const WGL_CONTEXT_MINOR_VERSION_ARB: i32 = 0x2092;
pub const WGL_CONTEXT_LAYER_PLANE_ARB: i32 = 0x2093;
pub const WGL_CONTEXT_FLAGS_ARB: i32 = 0x2094;
pub const WGL_CONTEXT_PROFILE_MASK_ARB: i32 = 0x9126;
pub const WGL_CONTEXT_DEBUG_BIT_ARB: u32 = 0x0001;
pub const WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB: u32 = 0x0002;
pub const WGL_CONTEXT_CORE_PROFILE_BIT_ARB: u32 = 0x00000001;
pub const WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB: u32 = 0x00000002;
pub const ERROR_INVALID_VERSION_ARB: DWORD = 0x2095;
pub const ERROR_INVALID_PROFILE_ARB: DWORD = 0x2096;
pub const ERROR_INCOMPATIBLE_DEVICE_CONTEXTS_ARB: DWORD = 0x2054;

pub const MAPVK_VK_TO_VSC: UINT = 0;
pub const MAPVK_VSC_TO_VK: UINT = 1;
pub const MAPVK_VK_TO_CHAR: UINT = 2;
pub const MAPVK_VSC_TO_VK_EX: UINT = 3;

pub const WGL_NUMBER_PIXEL_FORMATS_ARB: i32 = 0x2000;
pub const WGL_DRAW_TO_WINDOW_ARB: i32 = 0x2001;
pub const WGL_DRAW_TO_BITMAP_ARB: i32 = 0x2002;
pub const WGL_ACCELERATION_ARB: i32 = 0x2003;
pub const WGL_NEED_PALETTE_ARB: i32 = 0x2004;
pub const WGL_NEED_SYSTEM_PALETTE_ARB: i32 = 0x2005;
pub const WGL_SWAP_LAYER_BUFFERS_ARB: i32 = 0x2006;
pub const WGL_SWAP_METHOD_ARB: i32 = 0x2007;
pub const WGL_NUMBER_OVERLAYS_ARB: i32 = 0x2008;
pub const WGL_NUMBER_UNDERLAYS_ARB: i32 = 0x2009;
pub const WGL_TRANSPARENT_ARB: i32 = 0x200A;
pub const WGL_TRANSPARENT_RED_VALUE_ARB: i32 = 0x2037;
pub const WGL_TRANSPARENT_GREEN_VALUE_ARB: i32 = 0x2038;
pub const WGL_TRANSPARENT_BLUE_VALUE_ARB: i32 = 0x2039;
pub const WGL_TRANSPARENT_ALPHA_VALUE_ARB: i32 = 0x203A;
pub const WGL_TRANSPARENT_INDEX_VALUE_ARB: i32 = 0x203B;
pub const WGL_SHARE_DEPTH_ARB: i32 = 0x200C;
pub const WGL_SHARE_STENCIL_ARB: i32 = 0x200D;
pub const WGL_SHARE_ACCUM_ARB: i32 = 0x200E;
pub const WGL_SUPPORT_GDI_ARB: i32 = 0x200F;
pub const WGL_SUPPORT_OPENGL_ARB: i32 = 0x2010;
pub const WGL_DOUBLE_BUFFER_ARB: i32 = 0x2011;
pub const WGL_STEREO_ARB: i32 = 0x2012;
pub const WGL_PIXEL_TYPE_ARB: i32 = 0x2013;
pub const WGL_COLOR_BITS_ARB: i32 = 0x2014;
pub const WGL_RED_BITS_ARB: i32 = 0x2015;
pub const WGL_RED_SHIFT_ARB: i32 = 0x2016;
pub const WGL_GREEN_BITS_ARB: i32 = 0x2017;
pub const WGL_GREEN_SHIFT_ARB: i32 = 0x2018;
pub const WGL_BLUE_BITS_ARB: i32 = 0x2019;
pub const WGL_BLUE_SHIFT_ARB: i32 = 0x201A;
pub const WGL_ALPHA_BITS_ARB: i32 = 0x201B;
pub const WGL_ALPHA_SHIFT_ARB: i32 = 0x201C;
pub const WGL_ACCUM_BITS_ARB: i32 = 0x201D;
pub const WGL_ACCUM_RED_BITS_ARB: i32 = 0x201E;
pub const WGL_ACCUM_GREEN_BITS_ARB: i32 = 0x201F;
pub const WGL_ACCUM_BLUE_BITS_ARB: i32 = 0x2020;
pub const WGL_ACCUM_ALPHA_BITS_ARB: i32 = 0x2021;
pub const WGL_DEPTH_BITS_ARB: i32 = 0x2022;
pub const WGL_STENCIL_BITS_ARB: i32 = 0x2023;
pub const WGL_AUX_BUFFERS_ARB: i32 = 0x2024;
pub const WGL_NO_ACCELERATION_ARB: i32 = 0x2025;
pub const WGL_GENERIC_ACCELERATION_ARB: i32 = 0x2026;
pub const WGL_FULL_ACCELERATION_ARB: i32 = 0x2027;
pub const WGL_SWAP_EXCHANGE_ARB: i32 = 0x2028;
pub const WGL_SWAP_COPY_ARB: i32 = 0x2029;
pub const WGL_SWAP_UNDEFINED_ARB: i32 = 0x202A;
pub const WGL_TYPE_RGBA_ARB: i32 = 0x202B;
pub const WGL_TYPE_COLORINDEX_ARB: i32 = 0x202C;
pub const WGL_SAMPLE_BUFFERS_ARB: i32 = 0x2041;
pub const WGL_SAMPLES_ARB: i32 = 0x2042;

pub const CP_USASCII: UINT = 1252;
pub const CP_UNICODE: UINT = 1200;
pub const CP_JAUTODETECT: UINT = 50932;
pub const CP_KAUTODETECT: UINT = 50949;
pub const CP_ISO2022JPESC: UINT = 50221;
pub const CP_ISO2022JPSIO: UINT = 50222;
pub const CP_UTF8: UINT = 65001;

//#region Virtual Keys
pub const VK_LBUTTON: UINT = 0x01;
pub const VK_RBUTTON: UINT = 0x02;
pub const VK_CANCEL: UINT = 0x03;
pub const VK_MBUTTON: UINT = 0x04;
pub const VK_XBUTTON1: UINT = 0x05;
pub const VK_XBUTTON2: UINT = 0x06;
pub const VK_BACK: UINT = 0x08;
pub const VK_TAB: UINT = 0x09;
pub const VK_CLEAR: UINT = 0x0C;
pub const VK_RETURN: UINT = 0x0D;
pub const VK_SHIFT: UINT = 0x10;
pub const VK_CONTROL: UINT = 0x11;
pub const VK_MENU: UINT = 0x12;
pub const VK_PAUSE: UINT = 0x13;
pub const VK_CAPITAL: UINT = 0x14;
pub const VK_KANA: UINT = 0x15;
pub const VK_HANGEUL: UINT = 0x15;
pub const VK_HANGUL: UINT = 0x15;
pub const VK_IME_ON: UINT = 0x16;
pub const VK_JUNJA: UINT = 0x17;
pub const VK_FINAL: UINT = 0x18;
pub const VK_HANJA: UINT = 0x19;
pub const VK_KANJI: UINT = 0x19;
pub const VK_IME_OFF: UINT = 0x1A;
pub const VK_ESCAPE: UINT = 0x1B;
pub const VK_CONVERT: UINT = 0x1C;
pub const VK_NONCONVERT: UINT = 0x1D;
pub const VK_ACCEPT: UINT = 0x1E;
pub const VK_MODECHANGE: UINT = 0x1F;
pub const VK_SPACE: UINT = 0x20;
pub const VK_PRIOR: UINT = 0x21;
pub const VK_NEXT: UINT = 0x22;
pub const VK_END: UINT = 0x23;
pub const VK_HOME: UINT = 0x24;
pub const VK_LEFT: UINT = 0x25;
pub const VK_UP: UINT = 0x26;
pub const VK_RIGHT: UINT = 0x27;
pub const VK_DOWN: UINT = 0x28;
pub const VK_SELECT: UINT = 0x29;
pub const VK_PRINT: UINT = 0x2A;
pub const VK_EXECUTE: UINT = 0x2B;
pub const VK_SNAPSHOT: UINT = 0x2C;
pub const VK_INSERT: UINT = 0x2D;
pub const VK_DELETE: UINT = 0x2E;
pub const VK_HELP: UINT = 0x2F;

pub const VK_LWIN: UINT = 0x5B;
pub const VK_RWIN: UINT = 0x5C;
pub const VK_APPS: UINT = 0x5D;
pub const VK_SLEEP: UINT = 0x5F;
pub const VK_NUMPAD0: UINT = 0x60;
pub const VK_NUMPAD1: UINT = 0x61;
pub const VK_NUMPAD2: UINT = 0x62;
pub const VK_NUMPAD3: UINT = 0x63;
pub const VK_NUMPAD4: UINT = 0x64;
pub const VK_NUMPAD5: UINT = 0x65;
pub const VK_NUMPAD6: UINT = 0x66;
pub const VK_NUMPAD7: UINT = 0x67;
pub const VK_NUMPAD8: UINT = 0x68;
pub const VK_NUMPAD9: UINT = 0x69;
pub const VK_MULTIPLY: UINT = 0x6A;
pub const VK_ADD: UINT = 0x6B;
pub const VK_SEPARATOR: UINT = 0x6C;
pub const VK_SUBTRACT: UINT = 0x6D;
pub const VK_DECIMAL: UINT = 0x6E;
pub const VK_DIVIDE: UINT = 0x6F;
pub const VK_F1: UINT = 0x70;
pub const VK_F2: UINT = 0x71;
pub const VK_F3: UINT = 0x72;
pub const VK_F4: UINT = 0x73;
pub const VK_F5: UINT = 0x74;
pub const VK_F6: UINT = 0x75;
pub const VK_F7: UINT = 0x76;
pub const VK_F8: UINT = 0x77;
pub const VK_F9: UINT = 0x78;
pub const VK_F10: UINT = 0x79;
pub const VK_F11: UINT = 0x7A;
pub const VK_F12: UINT = 0x7B;
pub const VK_F13: UINT = 0x7C;
pub const VK_F14: UINT = 0x7D;
pub const VK_F15: UINT = 0x7E;
pub const VK_F16: UINT = 0x7F;
pub const VK_F17: UINT = 0x80;
pub const VK_F18: UINT = 0x81;
pub const VK_F19: UINT = 0x82;
pub const VK_F20: UINT = 0x83;
pub const VK_F21: UINT = 0x84;
pub const VK_F22: UINT = 0x85;
pub const VK_F23: UINT = 0x86;
pub const VK_F24: UINT = 0x87;
pub const VK_NUMLOCK: UINT = 0x90;
pub const VK_SCROLL: UINT = 0x91;
pub const VK_OEM_NEC_EQUAL: UINT = 0x92;
pub const VK_OEM_FJ_JISHO: UINT = 0x92;
pub const VK_OEM_FJ_MASSHOU: UINT = 0x93;
pub const VK_OEM_FJ_TOUROKU: UINT = 0x94;
pub const VK_OEM_FJ_LOYA: UINT = 0x95;
pub const VK_OEM_FJ_ROYA: UINT = 0x96;
pub const VK_LSHIFT: UINT = 0xA0;
pub const VK_RSHIFT: UINT = 0xA1;
pub const VK_LCONTROL: UINT = 0xA2;
pub const VK_RCONTROL: UINT = 0xA3;
pub const VK_LMENU: UINT = 0xA4;
pub const VK_RMENU: UINT = 0xA5;
pub const VK_BROWSER_BACK: UINT = 0xA6;
pub const VK_BROWSER_FORWARD: UINT = 0xA7;
pub const VK_BROWSER_REFRESH: UINT = 0xA8;
pub const VK_BROWSER_STOP: UINT = 0xA9;
pub const VK_BROWSER_SEARCH: UINT = 0xAA;
pub const VK_BROWSER_FAVORITES: UINT = 0xAB;
pub const VK_BROWSER_HOME: UINT = 0xAC;
pub const VK_VOLUME_MUTE: UINT = 0xAD;
pub const VK_VOLUME_DOWN: UINT = 0xAE;
pub const VK_VOLUME_UP: UINT = 0xAF;
pub const VK_MEDIA_NEXT_TRACK: UINT = 0xB0;
pub const VK_MEDIA_PREV_TRACK: UINT = 0xB1;
pub const VK_MEDIA_STOP: UINT = 0xB2;
pub const VK_MEDIA_PLAY_PAUSE: UINT = 0xB3;
pub const VK_LAUNCH_MAIL: UINT = 0xB4;
pub const VK_LAUNCH_MEDIA_SELECT: UINT = 0xB5;
pub const VK_LAUNCH_APP1: UINT = 0xB6;
pub const VK_LAUNCH_APP2: UINT = 0xB7;
pub const VK_OEM_1: UINT = 0xBA;
pub const VK_OEM_PLUS: UINT = 0xBB;
pub const VK_OEM_COMMA: UINT = 0xBC;
pub const VK_OEM_MINUS: UINT = 0xBD;
pub const VK_OEM_PERIOD: UINT = 0xBE;
pub const VK_OEM_2: UINT = 0xBF;
pub const VK_OEM_3: UINT = 0xC0;
pub const VK_OEM_4: UINT = 0xDB;
pub const VK_OEM_5: UINT = 0xDC;
pub const VK_OEM_6: UINT = 0xDD;
pub const VK_OEM_7: UINT = 0xDE;
pub const VK_OEM_8: UINT = 0xDF;
pub const VK_OEM_AX: UINT = 0xE1;
pub const VK_OEM_102: UINT = 0xE2;
pub const VK_ICO_HELP: UINT = 0xE3;
pub const VK_ICO_00: UINT = 0xE4;
pub const VK_PROCESSKEY: UINT = 0xE5;
pub const VK_ICO_CLEAR: UINT = 0xE6;
pub const VK_PACKET: UINT = 0xE7;
pub const VK_OEM_RESET: UINT = 0xE9;
pub const VK_OEM_JUMP: UINT = 0xEA;
pub const VK_OEM_PA1: UINT = 0xEB;
pub const VK_OEM_PA2: UINT = 0xEC;
pub const VK_OEM_PA3: UINT = 0xED;
pub const VK_OEM_WSCTRL: UINT = 0xEE;
pub const VK_OEM_CUSEL: UINT = 0xEF;
pub const VK_OEM_ATTN: UINT = 0xF0;
pub const VK_OEM_FINISH: UINT = 0xF1;
pub const VK_OEM_COPY: UINT = 0xF2;
pub const VK_OEM_AUTO: UINT = 0xF3;
pub const VK_OEM_ENLW: UINT = 0xF4;
pub const VK_OEM_BACKTAB: UINT = 0xF5;
pub const VK_ATTN: UINT = 0xF6;
pub const VK_CRSEL: UINT = 0xF7;
pub const VK_EXSEL: UINT = 0xF8;
pub const VK_EREOF: UINT = 0xF9;
pub const VK_PLAY: UINT = 0xFA;
pub const VK_ZOOM: UINT = 0xFB;
pub const VK_NONAME: UINT = 0xFC;
pub const VK_PA1: UINT = 0xFD;
pub const VK_OEM_CLEAR: UINT = 0xFE;
//#endregion

//#region System metrics
pub const SM_ARRANGE: i32 = 56;
pub const SM_CLEANBOOT: i32 = 67;
pub const SM_CMONITORS: i32 = 80;
pub const SM_CMOUSEBUTTONS: i32 = 43;
pub const SM_CONVERTIBLESLATEMODE: i32 = 0x2003;
pub const SM_CXBORDER: i32 = 5;
pub const SM_CXCURSOR: i32 = 13;
pub const SM_CXDLGFRAME: i32 = 7;
pub const SM_CXDOUBLECLK: i32 = 36;
pub const SM_CXDRAG: i32 = 68;
pub const SM_CXEDGE: i32 = 45;
pub const SM_CXFIXEDFRAME: i32 = 7;
pub const SM_CXFOCUSBORDER: i32 = 83;
pub const SM_CXFRAME: i32 = 32;
pub const SM_CXFULLSCREEN: i32 = 16;
pub const SM_CXHSCROLL: i32 = 21;
pub const SM_CXHTHUMB: i32 = 10;
pub const SM_CXICON: i32 = 11;
pub const SM_CXICONSPACING: i32 = 38;
pub const SM_CXMAXIMIZED: i32 = 61;
pub const SM_CXMAXTRACK: i32 = 59;
pub const SM_CXMENUCHECK: i32 = 71;
pub const SM_CXMENUSIZE: i32 = 54;
pub const SM_CXMIN: i32 = 28;
pub const SM_CXMINIMIZED: i32 = 57;
pub const SM_CXMINSPACING: i32 = 47;
pub const SM_CXMINTRACK: i32 = 34;
pub const SM_CXPADDEDBORDER: i32 = 92;
pub const SM_CXSCREEN: i32 = 0;
pub const SM_CXSIZE: i32 = 30;
pub const SM_CXSIZEFRAME: i32 = 32;
pub const SM_CXSMICON: i32 = 49;
pub const SM_CXSMSIZE: i32 = 52;
pub const SM_CXVIRTUALSCREEN: i32 = 78;
pub const SM_CXVSCROLL: i32 = 2;
pub const SM_CYBORDER: i32 = 6;
pub const SM_CYCAPTION: i32 = 4;
pub const SM_CYCURSOR: i32 = 14;
pub const SM_CYDLGFRAME: i32 = 8;
pub const SM_CYDOUBLECLK: i32 = 37;
pub const SM_CYDRAG: i32 = 69;
pub const SM_CYEDGE: i32 = 46;
pub const SM_CYFIXEDFRAME: i32 = 8;
pub const SM_CYFOCUSBORDER: i32 = 84;
pub const SM_CYFRAME: i32 = 33;
pub const SM_CYFULLSCREEN: i32 = 17;
pub const SM_CYHSCROLL: i32 = 3;
pub const SM_CYICON: i32 = 12;
pub const SM_CYICONSPACING: i32 = 39;
pub const SM_CYKANJIWINDOW: i32 = 18;
pub const SM_CYMAXIMIZED: i32 = 62;
pub const SM_CYMAXTRACK: i32 = 60;
pub const SM_CYMENU: i32 = 15;
pub const SM_CYMENUCHECK: i32 = 72;
pub const SM_CYMENUSIZE: i32 = 55;
pub const SM_CYMIN: i32 = 29;
pub const SM_CYMINIMIZED: i32 = 58;
pub const SM_CYMINSPACING: i32 = 48;
pub const SM_CYMINTRACK: i32 = 35;
pub const SM_CYSCREEN: i32 = 1;
pub const SM_CYSIZE: i32 = 31;
pub const SM_CYSIZEFRAME: i32 = 33;
pub const SM_CYSMCAPTION: i32 = 51;
pub const SM_CYSMICON: i32 = 50;
pub const SM_CYSMSIZE: i32 = 53;
pub const SM_CYVIRTUALSCREEN: i32 = 79;
pub const SM_CYVSCROLL: i32 = 20;
pub const SM_CYVTHUMB: i32 = 9;
pub const SM_DBCSENABLED: i32 = 42;
pub const SM_DEBUG: i32 = 22;
pub const SM_DIGITIZER: i32 = 94;
pub const SM_IMMENABLED: i32 = 82;
pub const SM_MAXIMUMTOUCHES: i32 = 95;
pub const SM_MEDIACENTER: i32 = 87;
pub const SM_MENUDROPALIGNMENT: i32 = 40;
pub const SM_MIDEASTENABLED: i32 = 74;
pub const SM_MOUSEPRESENT: i32 = 19;
pub const SM_MOUSEHORIZONTALWHEELPRESENT: i32 = 91;
pub const SM_MOUSEWHEELPRESENT: i32 = 75;
pub const SM_NETWORK: i32 = 63;
pub const SM_PENWINDOWS: i32 = 41;
pub const SM_REMOTECONTROL: i32 = 0x2001;
pub const SM_REMOTESESSION: i32 = 0x1000;
pub const SM_SAMEDISPLAYFORMAT: i32 = 81;
pub const SM_SECURE: i32 = 44;
pub const SM_SERVERR2: i32 = 89;
pub const SM_SHOWSOUNDS: i32 = 70;
pub const SM_SHUTTINGDOWN: i32 = 0x2000;
pub const SM_SLOWMACHINE: i32 = 73;
pub const SM_STARTER: i32 = 88;
pub const SM_SWAPBUTTON: i32 = 23;
pub const SM_SYSTEMDOCKED: i32 = 0x2004;
pub const SM_TABLETPC: i32 = 86;
pub const SM_XVIRTUALSCREEN: i32 = 76;
pub const SM_YVIRTUALSCREEN: i32 = 77;
//#endregion

pub const WNDCLASSEXW = extern struct {
    cbSize: UINT = @sizeOf(WNDCLASSEXW),
    style: UINT,
    lpfnWndProc: WNDPROC,
    cbClsExtra: i32 = 0,
    cbWndExtra: i32 = 0,
    hInstance: ?HINSTANCE = null,
    hIcon: ?HICON = null,
    hCursor: ?HCURSOR = null,
    hbrBackground: ?HBRUSH = null,
    lpszMenuName: ?LPCWSTR = null,
    lpszClassName: LPCWSTR,
    hIconSm: ?HICON = null,
};
pub const POINT = extern struct {
    x: LONG = 0,
    y: LONG = 0,
};
pub const RECT = extern struct {
    left: LONG = 0,
    top: LONG = 0,
    right: LONG = 0,
    bottom: LONG = 0,
};
pub const MSG = extern struct {
    hwnd: ?HWND,
    message: UINT,
    wParam: WPARAM,
    lParam: LPARAM,
    time: DWORD,
    pt: POINT,
};
pub const TASKDIALOGCONFIG = extern struct {
    cbSize: UINT = @sizeOf(TASKDIALOGCONFIG),
    hwndParent: ?HWND,
    hInstance: ?HINSTANCE,
    dwFlags: TASKDIALOG_FLAGS = .{},
    dwCommonButtons: TASKDIALOG_COMMON_BUTTON_FLAGS = .{},
    pszWindowTitle: LPCWSTR,
    DUMMYUNIONNAME: extern union {
        hMainIcon: ?HICON,
        pszMainIcon: ?LPCWSTR,
    } = .{ .hMainIcon = null },
    pszMainInstruction: ?LPCWSTR = null,
    pszContent: LPCWSTR,
    cButtons: UINT,
    pButtons: [*]const TASKDIALOG_BUTTON,
    nDefaultButton: u32 = 0,
    cRadioButtons: UINT = 0,
    pRadioButtons: ?[*]const TASKDIALOG_BUTTON = null,
    nDefaultRadioButton: u32 = 0,
    pszVerificationText: ?LPCWSTR = null,
    pszExpandedInformation: ?LPCWSTR = null,
    pszExpandedControlText: ?LPCWSTR = null,
    pszCollapsedControlText: ?LPCWSTR = null,
    DUMMYUNIONNAME2: extern union {
        hFooterIcon: ?HICON,
        pszFooterIcon: ?LPCWSTR,
    } = .{ .hFooterIcon = null },
    pszFooter: ?LPCWSTR = null,
    pfCallback: ?PFTASKDIALOGCALLBACK = null,
    lpCallbackData: LONG_PTR = 0,
    cxWidth: UINT = 0,
};
pub const TASKDIALOG_FLAGS = packed struct {
    ENABLE_HYPERLINKS: bool = false,
    USE_HICON_MAIN: bool = false,
    USE_HICON_FOOTER: bool = false,
    ALLOW_DIALOG_CANCELLATION: bool = false,
    USE_COMMAND_LINKS: bool = false,
    USE_COMMAND_LINKS_NO_ICON: bool = false,
    EXPAND_FOOTER_AREA: bool = false,
    EXPANDED_BY_DEFAULT: bool = false,
    VERIFICATION_FLAG_CHECKED: bool = false,
    SHOW_PROGRESS_BAR: bool = false,
    SHOW_MARQUEE_PROGRESS_BAR: bool = false,
    CALLBACK_TIMER: bool = false,
    POSITION_RELATIVE_TO_WINDOW: bool = false,
    RTL_LAYOUT: bool = false,
    NO_DEFAULT_RADIO_BUTTON: bool = false,
    CAN_BE_MINIMIZED: bool = false,
    NO_SET_FOREGROUND: bool = false,
    SIZE_TO_CONTENT: bool = false,
    _padding: u14 = 0,
};
pub const TASKDIALOG_COMMON_BUTTON_FLAGS = packed struct {
    OK_BUTTON: bool = false,
    YES_BUTTON: bool = false,
    NO_BUTTON: bool = false,
    CANCEL_BUTTON: bool = false,
    RETRY_BUTTON: bool = false,
    CLOSE_BUTTON: bool = false,
    _padding: u26 = 0,
};
pub const TASKDIALOG_BUTTON = extern struct {
    nButtonID: u32,
    pszButtonText: LPCWSTR,
};
pub const PIXELFORMATDESCRIPTOR = extern struct {
    nSize: WORD = @sizeOf(PIXELFORMATDESCRIPTOR),
    nVersion: WORD = 0,
    dwFlags: DWORD = 0,
    iPixelType: BYTE = 0,
    cColorBits: BYTE = 0,
    cRedBits: BYTE = 0,
    cRedShift: BYTE = 0,
    cGreenBits: BYTE = 0,
    cGreenShift: BYTE = 0,
    cBlueBits: BYTE = 0,
    cBlueShift: BYTE = 0,
    cAlphaBits: BYTE = 0,
    cAlphaShift: BYTE = 0,
    cAccumBits: BYTE = 0,
    cAccumRedBits: BYTE = 0,
    cAccumGreenBits: BYTE = 0,
    cAccumBlueBits: BYTE = 0,
    cAccumAlphaBits: BYTE = 0,
    cDepthBits: BYTE = 0,
    cStencilBits: BYTE = 0,
    cAuxBuffers: BYTE = 0,
    iLayerType: BYTE = 0,
    bReserved: BYTE = 0,
    dwLayerMask: DWORD = 0,
    dwVisibleMask: DWORD = 0,
    dwDamageMask: DWORD = 0,
};
pub const MINMAXINFO = extern struct {
    ptReserved: POINT,
    ptMaxSize: POINT,
    ptMaxPosition: POINT,
    ptMinTrackSize: POINT,
    ptMaxTrackSize: POINT,
};
pub const DEV_BROADCAST_DEVICEINTERFACE_W = extern struct {
    dbcc_size: DWORD,
    dbcc_devicetype: DWORD,
    dbcc_reserved: DWORD,
    dbcc_classguid: GUID,
    dbcc_name: [1]u16,
};
pub const GUID = extern struct {
    Data1: u32,
    Data2: u16,
    Data3: u16,
    Data4: [8]u8,
};

pub const HRESULT = i32;
pub inline fn SUCCEEDED(hr: HRESULT) bool {
    return hr >= 0;
}
pub inline fn FAILED(hr: HRESULT) bool {
    return hr < 0;
}

//#region Kernel32
pub extern "Kernel32" fn GetModuleHandleW(lpModuleName: ?LPCWSTR) callconv(WINAPI) HMODULE;
pub extern "Kernel32" fn GetLastError() callconv(WINAPI) DWORD;
pub extern "Kernel32" fn SetConsoleOutputCP(wCodePageID: UINT) callconv(WINAPI) BOOL;
//#endregion

//#region User32
pub extern "User32" fn GetSystemMetrics(nIndex: i32) callconv(WINAPI) i32;
pub extern "User32" fn CreateWindowExW(dwExtStyle: DWORD, lpClassName: ?LPCWSTR, lpWindowName: ?LPCWSTR, dwStyle: DWORD, x: i32, y: i32, nWidth: i32, nHeight: i32, hWndParent: ?HWND, hWndMenu: ?HWND, hInstance: ?HINSTANCE, lpParam: ?LPVOID) callconv(WINAPI) ?HWND;
pub extern "User32" fn DestroyWindow(hWnd: HWND) callconv(WINAPI) BOOL;
pub extern "User32" fn DefWindowProcW(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) callconv(WINAPI) LRESULT;
pub extern "User32" fn RegisterClassExW(class: *const WNDCLASSEXW) callconv(WINAPI) ATOM;
pub extern "User32" fn UnregisterClassW(lpClassName: LPCWSTR, hInstance: ?HINSTANCE) callconv(WINAPI) BOOL;
pub extern "User32" fn LoadCursorW(hInstance: ?HINSTANCE, lpCursorName: LPCWSTR) callconv(WINAPI) ?HCURSOR;
pub extern "User32" fn GetPropW(hWnd: HWND, lpString: LPCWSTR) callconv(WINAPI) ?HANDLE;
pub extern "User32" fn SetPropW(hWnd: HWND, lpString: LPCWSTR, hData: HANDLE) callconv(WINAPI) BOOL;
pub extern "User32" fn GetActiveWindow() callconv(WINAPI) ?HWND;
pub extern "User32" fn SetActiveWindow(hWnd: HWND) callconv(WINAPI) ?HWND;
pub extern "User32" fn SetFocus(hWnd: ?HWND) callconv(WINAPI) ?HWND;
pub extern "User32" fn PeekMessageW(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT, wRemoveMsg: UINT) callconv(WINAPI) BOOL;
pub extern "User32" fn TranslateMessage(lpMsg: *const MSG) callconv(WINAPI) BOOL;
pub extern "User32" fn DispatchMessageW(lpMsg: *const MSG) callconv(WINAPI) LRESULT;
pub extern "User32" fn ClientToScreen(hWnd: HWND, lpPoint: *POINT) callconv(WINAPI) BOOL;
pub extern "User32" fn AdjustWindowRectEx(lpRect: *RECT, dwStyle: DWORD, bMenu: BOOL, dwExStyle: DWORD) BOOL;
pub extern "User32" fn GetClientRect(hWnd: HWND, lprect: *RECT) callconv(WINAPI) BOOL;
pub extern "User32" fn SetWindowPos(hWnd: HWND, hWndInsertAfter: ?HWND, X: i32, Y: i32, cx: i32, cy: i32, uFlags: UINT) callconv(WINAPI) BOOL;
pub extern "User32" fn GetDC(hWnd: HWND) callconv(WINAPI) ?HDC;
pub extern "User32" fn ReleaseDC(hWnd: HWND, dc: HDC) callconv(WINAPI) BOOL;
pub extern "User32" fn ShowWindow(hWnd: HWND, nCmdShow: i32) callconv(WINAPI) BOOL;
pub extern "User32" fn SetWindowTextW(hWnd: HWND, lpString: ?LPCWSTR) callconv(WINAPI) BOOL;
pub extern "User32" fn GetWindowTextLengthW(hWnd: HWND) callconv(WINAPI) i32;
pub extern "User32" fn GetWindowTextW(hWnd: HWND, lpString: LPWSTR, nMaxCount: i32) callconv(WINAPI) i32;
pub extern "User32" fn GetWindowRect(hWnd: HWND, lpRect: *RECT) callconv(WINAPI) BOOL;
pub extern "User32" fn MoveWindow(hWnd: HWND, x: i32, y: i32, nWidth: i32, nHeight: i32, bRepaint: BOOL) callconv(WINAPI) BOOL;
pub extern "User32" fn GetCursorPos(lpPoint: *POINT) callconv(WINAPI) BOOL;
pub extern "User32" fn SetCursorPos(x: i32, y: i32) callconv(WINAPI) BOOL;
pub extern "User32" fn ScreenToClient(hWnd: HWND, lpPoint: *POINT) callconv(WINAPI) BOOL;
pub extern "User32" fn SetCursor(hCurser: ?HCURSOR) callconv(WINAPI) HCURSOR;
pub extern "User32" fn ClipCursor(lpRect: ?*const RECT) callconv(WINAPI) BOOL;
pub extern "User32" fn WindowFromPoint(Point: POINT) callconv(WINAPI) ?HWND;
pub extern "User32" fn PtInRect(lprc: *const RECT, Point: POINT) callconv(WINAPI) BOOL;
pub extern "User32" fn ShowCursor(bShow: BOOL) callconv(WINAPI) i32;
pub extern "User32" fn GetKeyState(nVirtKey: i32) callconv(WINAPI) SHORT;
pub extern "User32" fn MapVirtualKeyW(uCode: UINT, uMapType: UINT) callconv(WINAPI) UINT;
pub extern "User32" fn GetMessageTime() callconv(WINAPI) LONG;
pub extern "User32" fn MessageBoxW(hWnd: ?HWND, lpText: ?LPCWSTR, lpCaption: ?LPCWSTR, uType: UINT) callconv(WINAPI) i32;
pub extern "User32" fn ToUnicode(wVirtKey: UINT, wScanCode: UINT, lpKeyState: ?*const [256]BYTE, pwszBuff: LPWSTR, cchBuff: i32, wFlags: UINT) callconv(WINAPI) i32;
pub extern "User32" fn SendMessage(hWnd: HWND, msg: UINT, wParam: WPARAM, lParam: LPARAM) callconv(WINAPI) LRESULT;
//#endregion

//#region Comctl32
pub extern "Comctl32" fn TaskDialogIndirect(pTaskConfig: *const TASKDIALOGCONFIG, pnButton: ?*i32, pnRadioButton: ?*i32, pfVerificationFlagChecked: ?*BOOL) callconv(WINAPI) HRESULT;
//#endregion

//#region Opengl32
pub extern "Opengl32" fn wglCreateContext(hdc: HDC) callconv(WINAPI) ?HGLRC;
pub extern "Opengl32" fn wglDeleteContext(hglrc: HGLRC) callconv(WINAPI) BOOL;
pub extern "Opengl32" fn wglMakeCurrent(hdc: HDC, hglrc: ?HGLRC) callconv(WINAPI) BOOL;
pub extern "Opengl32" fn wglGetProcAddress(name: [*:0]const u8) callconv(WINAPI) ?*const anyopaque;
pub extern "Opengl32" fn wglShareLists(hglrc1: HGLRC, hglrc2: HGLRC) callconv(WINAPI) BOOL;
//#endregion

//#region Gdi32
pub extern "Gdi32" fn SetPixelFormat(hdc: HDC, format: i32, ppfd: *const PIXELFORMATDESCRIPTOR) callconv(WINAPI) BOOL;
pub extern "Gdi32" fn ChoosePixelFormat(hdc: HDC, ppfd: *const PIXELFORMATDESCRIPTOR) callconv(WINAPI) i32;
pub extern "Gdi32" fn SwapBuffers(hdc: HDC) callconv(WINAPI) BOOL;
//#endregion
