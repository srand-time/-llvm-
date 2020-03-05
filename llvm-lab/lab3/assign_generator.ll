; ModuleID = 'assign'
source_filename = "assign"

define i32 @main() {
entry:
  %0 = alloca i32
  store i32 1, i32* %0
  %1 = load i32, i32* %0
  ret i32 %1
}

