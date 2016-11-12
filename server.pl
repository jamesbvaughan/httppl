% main routine for accepting an http request and sending the requested file
main :-
    socket('AF_INET', Socket),
    socket_bind(Socket, 'AF_INET'('localhost', 3000)),
    socket_listen(Socket, 1),
    write('server listening on port 3000\n'),
    flush_output,
    socket_accept(Socket, StreamIn, StreamOut),
    read_request(StreamIn, Request),
    parse_request(Request, Path),
    read_file(Path, FileContent),
    construct_response(FileContent, Response),
    write(StreamOut, Response),
    socket_close(Socket).


% constructs a valid http response to be sent to the client
construct_response(Body, Response) :-
    atom_length(Body, Length),
    number_atom(Length, LengthAtom),
    atom_concat('Content-Length: ', LengthAtom, LengthHeader),
    atom_concat(LengthHeader, '\r\n\r\n', Headers),
    atom_concat('HTTP/1.0 200 OK\r\n', Headers, ResponseTop),
    atom_concat(ResponseTop, Body, Response).


% parses an http request, extracting the requested path
parse_request(Request, Path) :-
    atom_concat(RequestPrefix, RequestSuffix, Request),
    atom_concat('GET /', Path, RequestPrefix),
    atom_concat(' HTTP/', _, RequestSuffix).


% reads in a request, character by character, from the client
read_request(Stream, Request) :-
    read_request(Stream, '', Request).

read_request(_, Request, Request) :-
    atom_concat(_, '\r\n\r\n', Request).

read_request(Stream, SoFar, Request) :-
    get_char(Stream, NextChar),
    atom_concat(SoFar, NextChar, Next),
    read_request(Stream, Next, Request).


% read in the contents of the file at the given path
read_file(Path, Contents) :-
    open(Path, read, Stream),
    read_file_helper(Stream, Contents).

read_file_helper(Stream, '') :-
    at_end_of_stream(Stream).

read_file_helper(Stream, Contents) :-
    \+ at_end_of_stream(Stream),
    get_char(Stream, Head),
    read_file_helper(Stream, Tail),
    atom_concat(Head, Tail, Contents).
