const std = @import("std");
const ariadne = @import("ariadne");

fn read_file(alloc: std.mem.Allocator, file_path: []u8) ![]u8 {
    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    const stat = try file.stat();

    return try in_stream.readAllAlloc(alloc, stat.size);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const alloc = gpa.allocator();

    defer {
        const deinit_status = gpa.deinit();

        if (deinit_status == .leak) @panic("Memory leak");
    }

    const file_name = try std.fmt.allocPrint(alloc, "src/sample.tao", .{});
    defer alloc.free(file_name);

    const source = try read_file(alloc, file_name);
    defer alloc.free(source);

    var mAriadne = ariadne.Ariadne.init(alloc);
    defer mAriadne.deinit();

    mAriadne.addSourceFile(file_name, source);

    var labels = std.ArrayList(ariadne.Label).init(alloc);
    defer labels.deinit();

    try labels.append(mAriadne.createLabel(file_name, .{
        .start = 1,
        .end = 5,
    }, ariadne.COLORS.BLUE, @ptrCast(@constCast("Pls fix code :)"))));

    try labels.append(mAriadne.createLabel(file_name, .{
        .start = 7,
        .end = 8,
    }, ariadne.COLORS.RED, @ptrCast(@constCast("Now just delete this code"))));

    const diagnostic = ariadne.Diagnostic{
        .message = @ptrCast(@constCast("Looks like there was an err!")),
        .error_code = 5,
        .file_id = file_name,
        .kind = .Error,
        .labels = labels.items,
    };

    try mAriadne.printDiagnostic(diagnostic);
}
