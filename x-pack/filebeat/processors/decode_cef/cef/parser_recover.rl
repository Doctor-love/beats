// Code generated by ragel DO NOT EDIT.

package cef

import (
    "fmt"
    "strconv"

    "go.uber.org/multierr"
)

%%{
    machine cef_recover;
    write data;
    variable p p;
    variable pe pe;
}%%

// recoverExtensions unpacks a CEF message's extensions from messages with incomplete headers.
func (e *Event) recoverExtensions(data string) error {
    cs, p, pe, eof := 0, 0, len(data), len(data)
    mark, mark_slash := 0, 0

    // state related to CEF values.
    var state cefState

    // recoveredErrs are problems with the message that the parser was able to
    // recover from (though the parsing might not be "correct").
    var recoveredErrs []error

    // Bait and switch to keep the header fields that
    // we were able to get from the initial parse.
    // e was already initialised by the call to unpack.
    t := *e

    %%{
        include cef "cef_actions.rl";
        include cef "cef.rl";

        # Best effort header parser.
        header = version pipe
                (device_vendor pipe
                (device_product pipe
                (device_version pipe
                (device_event_class_id pipe
                (name pipe
                (severity pipe)?)?)?)?)?)?;

        # CEF message.
        cef = header %incomplete_header extensions;

        main := cef;
        write init;
        write exec;
    }%%

    // Copy back the extensions.
    t.Extensions = e.Extensions
    *e = t

    return multierr.Combine(recoveredErrs...)
}
