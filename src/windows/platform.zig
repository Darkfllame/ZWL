const std = @import("std");
const Zwl = @import("../Zwl.zig");
const init = @import("init.zig");
const window = @import("window.zig");
const event = @import("event.zig");
const context = @import("context.zig");

const Platform = Zwl.Platform;

pub const NativeData = init.NativeData;
pub const Window = window.NativeWindow;
pub const GLContext = context.GLContext;
pub const platform = Zwl.Platform{
    .init = &init.init,
    .deinit = &init.deinit,
    .keyName = &init.keyName,
    .window = .{
        .createMessageBox = &window.NativeWindow.createMessageBox,
        .init = &window.NativeWindow.init,
        .deinit = &window.NativeWindow.deinit,
        .setPosition = &window.NativeWindow.setPosition,
        .setSize = &window.NativeWindow.setSize,
        .setSizeLimits = &window.NativeWindow.setSizeLimits,
        .getFramebufferSize = &window.NativeWindow.getFramebufferSize,
        .setVisible = &window.NativeWindow.setVisible,
        .setTitle = &window.NativeWindow.setTitle,
        .isFocused = &window.NativeWindow.isFocused,
        .getMousePos = &window.NativeWindow.getMousePos,
        .setMousePos = &window.NativeWindow.setMousePos,
        .setMouseVisible = &window.NativeWindow.setMouseVisible,
        .setFocus = &window.NativeWindow.setFocus,
        .setMouseConfined = &window.NativeWindow.setMouseConfined,
    },
    .event = .{
        .pollEvent = &event.pollEvent,
    },
    .glContext = .{
        .init = &context.GLContext.init,
        .deinit = &context.GLContext.deinit,
        .makeCurrent = &context.GLContext.makeCurrent,
        .swapBuffers = &context.GLContext.swapBuffers,
        .swapInterval = &context.GLContext.swapInterval,
    },
};