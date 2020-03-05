; ModuleID = 'gcd.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @gcd(i32 %u, i32 %v) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 %u, i32* %2, align 4
  store i32 %v, i32* %3, align 4
  %4 = load i32, i32* %3, align 4
  %5 = icmp eq i32 %4, 0			;if(v==0)
  br i1 %5, label %6, label %8

; <label>:6                                       ; preds = %0
  %7 = load i32, i32* %2, align 4
  store i32 %7, i32* %1, align 4
  br label %18

; <label>:8                                       ; preds = %0
  %9 = load i32, i32* %3, align 4
  %10 = load i32, i32* %2, align 4
  %11 = load i32, i32* %2, align 4
  %12 = load i32, i32* %3, align 4
  %13 = sdiv i32 %11, %12
  %14 = load i32, i32* %3, align 4
  %15 = mul nsw i32 %13, %14
  %16 = sub nsw i32 %10, %15
  %17 = call i32 @gcd(i32 %9, i32 %16)
  store i32 %17, i32* %1, align 4
  br label %18

; <label>:18                                      ; preds = %8, %6
  %19 = load i32, i32* %1, align 4
  ret i32 %19
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %temp = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 72, i32* %x, align 4
  store i32 18, i32* %y, align 4
  %2 = load i32, i32* %x, align 4
  %3 = load i32, i32* %y, align 4
  %4 = icmp slt i32 %2, %3
  br i1 %4, label %5, label %9

; <label>:5                                       ; preds = %0
  %6 = load i32, i32* %x, align 4
  store i32 %6, i32* %temp, align 4
  %7 = load i32, i32* %y, align 4
  store i32 %7, i32* %x, align 4
  %8 = load i32, i32* %temp, align 4
  store i32 %8, i32* %y, align 4
  br label %9

; <label>:9                                       ; preds = %5, %0
  %10 = load i32, i32* %x, align 4
  %11 = load i32, i32* %y, align 4
  %12 = call i32 @gcd(i32 %10, i32 %11)
  ret i32 %12
}

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
