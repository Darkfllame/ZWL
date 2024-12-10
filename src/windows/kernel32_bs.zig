//! Kernel32 bootstrap for foreign compilation

pub export fn GetModuleHandleW() noreturn {
    @panic("Unexpected");
}
pub export fn GetLastError() noreturn {
    @panic("Unexpected");
}
