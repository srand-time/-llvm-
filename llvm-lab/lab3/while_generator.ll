; ModuleID = 'while'
source_filename = "while"

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  store i32 10, i32* %0
  store i32 0, i32* %1

; <label>:2:                                      ; preds = %trueBB, %2
  br label %2
  %3 = load i32, i32* %1
  %4 = icmp slt i32 %3, 10
  br i1 %4, label %trueBB, label %falseBB

falseBB:                                          ; preds = %2
  %5 = load i32, i32* %0
  ret i32 %5

trueBB:                                           ; preds = %2
  %6 = load i32, i32* %1
  %7 = add nsw i32 1, %6
  store i32 %7, i32* %1
  %8 = load i32, i32* %0
  %9 = load i32, i32* %1
  %10 = add nsw i32 %8, %9
  store i32 %10, i32* %0
  br label %2
}



