; ModuleID = 'assign'
source_filename = "assign"

define i32 @main() {
entry:
  br i1 true, label %trueBB, label %falseBB

trueBB:                                           ; preds = %entry
  ret i32 1

falseBB:                                          ; preds = %entry
  ret i32 0
}

