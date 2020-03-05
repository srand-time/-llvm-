; ModuleID = 'while.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

;parts of notes from https://blog.csdn.net/wy7980/article/details/46715703
;根据llvm.org上的描述，@代表全局变量，%代表局部变量,
;那么无疑，在llvm IR看来，int main这个函数，或者说他的函数返回值是个全局变量，其内部的a 和b是局部变量。
; Function Attrs: nounwind uwtable
define i32 @main() #0 {				;int main,it is global,so used @ 
  ;%1 = alloca i32, align 4	;maybe it is room for return value,but i donnot think it is useful for this function 			
;i32, align 4的意义就应该是：向4对齐，即便数据没有占用4个字节，也要为其分配4字节，这样使得llvm IR在保证了数据格式一致性的前提条件下，定义数据型时非常
;灵活，不仅可以任意定义整形和浮点型的长度(iX,iXX,iXXX………).
  %a = alloca i32, align 4			;int a
  %i = alloca i32, align 4			;int i			
  store i32 10, i32* %a, align 4		;a=10
  store i32 0, i32* %i, align 4			;i=0
  

  ;start while
  br label %1
  %2 = load i32, i32* %i, align 4
  %3 = icmp slt i32 %2, 10			;Icmp可以根据两个整数值的比较（op1，op2）返回一个布尔类型的值.if(i<10) 
  br i1 %3, label %4, label %10			;by %3,judge which label to excutute.if(%3==1) excute label 4
;Br提供一个选择分支结构，可根据cond的情况使程序转向label 或label ； 
;另外br也有一种特殊形式：无条件分支（Unconditional branch）
;当在某种情况时；不必进行条件判断而直接跳转至某一个特定的程序入口标签（label）处（感觉类似于一个“goto”
; <label>:4                                      
  %5 = load i32, i32* %i, align 4               ;load i to %5
  %6 = add nsw i32 %5, 1			;i=i+1
  store i32 %6, i32* %i, align 4                ;store i to memory
  
  %7 = load i32, i32* %a, align 4
  %8 = load i32, i32* %i, align 4
  %9 = add nsw i32 %7, %8			;%9=a+i
  store i32 %9, i32* %a, align 4		;a=%9
  br label %1					;go to the up label %1
  ;end while

; <label>:10                                     
  %11 = load i32, i32* %a, align 4
  ret i32 %11					;return value,now it is a
}


;I cannot unsderstand below,maybe we just need ctrl+c and ctrl+v
attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
