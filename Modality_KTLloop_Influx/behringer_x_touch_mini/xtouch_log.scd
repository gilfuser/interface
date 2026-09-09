(
    var old_window = ~xtouch_log_window;

    ~xtouch_log_revision = "2026-08-08-log-palette-v2";

    ~xtouch_log_lines = ~xtouch_log_lines ? List.new;
    ~xtouch_log_max_lines = 80;
    ~xtouch_log_visible = true;

    ~open_xtouch_log = {
        var screen = Window.availableBounds;
        var width = 380;
        var height = 160;
        var window;
        var view;
        var text;

        if (
            ~xtouch_log_window.isNil
            or: { ~xtouch_log_window.isClosed }
        ) {
            window = Window(
                "X-Touch / Tidal",
                Rect(0, 0, width, height),
                true
            );

            window.setTopLeftBounds(
                Rect(screen.right - width - 12, screen.top + 12, width, height),
                0
            );
            window.alwaysOnTop_(true);

            view = TextView(window, Rect(0, 0, width, height))
            .editable_(false)
            .hasHorizontalScroller_(false)
            .hasVerticalScroller_(true)
            .autohidesScrollers_(true)
            .palette_(QPalette.dark)
            .background_(Color.grey(0.08))
            .stringColor_(Color.grey(0.9))
            .font_(Font("Consolas", 10));

            window.layout_(VLayout(view));
            window.onClose_({
                if (~xtouch_log_window === window) {
                    ~xtouch_log_window = nil;
                    ~xtouch_log_view = nil;
                    ~xtouch_log_visible = false;
                };
            });

            ~xtouch_log_window = window;
            ~xtouch_log_view = view;
        };

        ~xtouch_log_visible = true;
        text = ~xtouch_log_lines.join("\n");
        ~xtouch_log_view.string_(text);
        ~xtouch_log_view.select(text.size, 0);
        ~xtouch_log_window.front;
    };

    ~xtouch_log = { |message|
        {
            message.asString.split($\n).do { |line|
                if (line.size > 0) {
                    ~xtouch_log_lines.add(line);
                };
            };

            while { ~xtouch_log_lines.size > ~xtouch_log_max_lines } {
                ~xtouch_log_lines.removeAt(0);
            };

            if (
                ~xtouch_log_visible
                and: { ~xtouch_log_view.notNil }
                and: { ~xtouch_log_view.isClosed.not }
            ) {
                var text = ~xtouch_log_lines.join("\n");

                ~xtouch_log_view.string_(text);
                ~xtouch_log_view.select(text.size, 0);
            };
        }.defer;

        message;
    };

    ~clear_xtouch_log = {
        {
            ~xtouch_log_lines.clear;

            if (
                ~xtouch_log_view.notNil
                and: { ~xtouch_log_view.isClosed.not }
            ) {
                ~xtouch_log_view.string_("");
            };
        }.defer;
    };

    {
        if (old_window.notNil and: { old_window.isClosed.not }) {
            old_window.onClose_(nil);
            old_window.close;
        };

        ~xtouch_log_window = nil;
        ~xtouch_log_view = nil;
        ~open_xtouch_log.value;
    }.defer;
);
