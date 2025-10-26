const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    std.debug.print("Let's draw\n", .{});

    const a = try String.from("Hello, World!");
    const b = try String.from("\nHello, Raylib!");
    const c = try a.concat(&b);

    rl.setConfigFlags(.{
        .window_resizable = true,
        .msaa_4x_hint = true,
    });

    rl.initWindow(960, 640, "Draw");

    const arial = try rl.loadFontEx(
        "resources/fonts/arial.ttf",
        24,
        null,
    );

    const text: Text = .{
        .text = &c,
        .position = .{
            .x = 16,
            .y = 16,
        },
        .style = .{
            .font = &arial,
            .font_size = 24,
            .spacing = 6,
            .color = rl.Color.white,
        },
    };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();

        rl.clearBackground(rl.Color.black);

        text.draw();

        rl.endDrawing();
    }
}

var alloc_impl: std.heap.DebugAllocator(.{}) = .init;

var alloc: std.mem.Allocator = alloc_impl.allocator();

const String = struct {
    data: [:0]u8,

    inline fn eq(self: *const String, other: *const String) bool {
        return std.mem.eql(u8, self.data, other.data);
    }

    fn concat(self: *const String, other: *const String) !String {
        const len = self.data.len + other.data.len;

        const data: [:0]u8 = try alloc.allocSentinel(u8, len, 0);

        for (data[0..self.data.len], self.data) |*b, c| {
            b.* = c;
        }

        for (data[self.data.len..len], other.data) |*b, c| {
            b.* = c;
        }

        return .{ .data = data };
    }

    inline fn from(str: []const u8) !String {
        const data: [:0]u8 = try alloc.allocSentinel(u8, str.len, 0);

        std.mem.copyForwards(u8, data, str);

        return .{ .data = data };
    }
};

const Text = struct {
    text: *const String,
    position: rl.Vector2,
    style: struct {
        font: *const rl.Font,
        font_size: f32,
        spacing: f32,
        color: rl.Color,
    },

    fn draw(self: *const Text) void {
        rl.drawTextEx(
            self.style.font.*,
            self.text.data,
            self.position,
            self.style.font_size,
            self.style.spacing,
            self.style.color,
        );
    }
};
