const std = @import("std");
const ZWL = @import("../zwl.zig");
const init = @import("init.zig");
const window = @import("window.zig");
const event = @import("event.zig");
const context = @import("context.zig");

const Platform = ZWL.Platform;

pub const NativeData = init.NativeData;
pub const Window = window.NativeWindow;
pub const GLContext = context.GLContext;

pub fn setPlatform(lib: *Platform) ZWL.Error!void {
    lib.* = .{
        .init = init.init,
        .deinit = init.deinit,
        .window = .{
            .createMessageBox = window.NativeWindow.createMessageBox,
            .init = window.NativeWindow.init,
            .deinit = window.NativeWindow.deinit,
            .setPosition = window.NativeWindow.setPosition,
            .getSize = window.NativeWindow.getSize,
            .setSize = window.NativeWindow.setSize,
            .setSizeLimits = window.NativeWindow.setSizeLimits,
            .getFramebufferSize = window.NativeWindow.getFramebufferSize,
            .setVisible = window.NativeWindow.setVisible,
            .setTitle = window.NativeWindow.setTitle,
            .getTitle = window.NativeWindow.getTitle,
            .isFocused = window.NativeWindow.isFocused,
            .getMousePos = window.NativeWindow.getMousePos,
            .setMousePos = window.NativeWindow.setMousePos,
            .setMouseVisible = window.NativeWindow.setMouseVisible,
            .getKey = window.NativeWindow.getKey,
        },
        .event = .{
            .pollEvent = event.pollEvent,
        },
        .glContext = .{
            .init = context.GLContext.init,
            .deinit = context.GLContext.deinit,
            .makeCurrent = context.GLContext.makeCurrent,
            .swapBuffers = context.GLContext.swapBuffers,
            .swapInterval = context.GLContext.swapInterval,
        },
    };
}
