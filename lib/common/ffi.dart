part of 'index.dart';

final lib = Platform.isAndroid
    ? ffi.DynamicLibrary.open('librust_lib.so')
    : ffi.DynamicLibrary.process();

final myFunction = lib
    .lookup<ffi.NativeFunction<ffi.Int32 Function()>>('my_function')
    .asFunction<int Function()>();
