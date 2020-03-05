; ModuleID = 'call'
source_filename = "call"

define i32 @callee(i32) {
entry:
  %1 = alloca i32
  store i32 %0, i32* %1
  %2 = load i32, i32* %1
  %3 = mul nsw i32 2, %2
  ret i32 %3
}

define i32 @main() {
entry:
  %0 = alloca i32
  store i32 10, i32* %0
  %1 = load i32, i32* %0
  %2 = call i32 @callee(i32 %1)
  ret i32 %2
}

