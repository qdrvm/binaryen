;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.

;; Check that tail calls are parsed, validated, and printed correctly

;; RUN: foreach %s %t wasm-opt -all -S -o - | filecheck %s
;; TODO: --nominal as well

(module

  ;; CHECK:      (type $void (func))
  (type $void (func))

  ;; CHECK:      (table $t 1 1 funcref)
  (table $t 1 1 funcref)

  ;; CHECK:      (elem $e (i32.const 0) $foo)
  (elem $e (i32.const 0) $foo)

  ;; CHECK:      (func $foo
  ;; CHECK-NEXT:  (return_call $bar)
  ;; CHECK-NEXT: )
  (func $foo
    (return_call $bar)
  )

  ;; CHECK:      (func $bar
  ;; CHECK-NEXT:  (return_call_indirect $t (type $void)
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $bar
    (return_call_indirect (type $void) (i32.const 0))
  )
)

;; Check GC types and subtyping
(module
  ;; CHECK:      (type $return-B (func (result (ref $B))))
  (type $return-B (func (result (ref $B))))

  ;; CHECK:      (type $return-A (func (result (ref null $A))))
  (type $return-A (func (result (ref null $A))))

  ;; CHECK:      (type $A (struct (field i32)))
  (type $A (struct i32))

  ;; CHECK:      (type $B (struct (field i32) (field i32)))
  (type $B (struct i32 i32) (supertype $A))

  ;; CHECK:      (table $t 1 1 funcref)
  (table $t 1 1 funcref)

  ;; CHECK:      (elem $e (i32.const 0) $callee)
  (elem $e (i32.const 0) $callee)

  ;; CHECK:      (func $caller (result (ref null $A))
  ;; CHECK-NEXT:  (return_call $callee)
  ;; CHECK-NEXT: )
  (func $caller (type $return-A)
    (return_call $callee)
  )

  ;; CHECK:      (func $caller-indirect (result (ref $B))
  ;; CHECK-NEXT:  (return_call_indirect $t (type $return-B)
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller-indirect (type $return-B)
    (return_call_indirect $t (type $return-B) (i32.const 0))
  )

  ;; CHECK:      (func $callee (result (ref $B))
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  (func $callee (type $return-B)
    (unreachable)
  )
)
