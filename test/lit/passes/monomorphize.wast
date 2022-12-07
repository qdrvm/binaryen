;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; Test in both "always" mode, which always monomorphizes, and in "careful"
;; mode which does it only when it appears to actually help.

;; RUN: foreach %s %t wasm-opt --nominal --monomorphize-always -all -S -o - | filecheck %s --check-prefix ALWAYS
;; RUN: foreach %s %t wasm-opt --nominal --monomorphize        -all -S -o - | filecheck %s --check-prefix CAREFUL

(module
  ;; ALWAYS:      (type $A (struct ))
  ;; CAREFUL:      (type $A (struct ))
  (type $A (struct_subtype data))
  ;; ALWAYS:      (type $B (struct_subtype  $A))
  ;; CAREFUL:      (type $B (struct_subtype  $A))
  (type $B (struct_subtype $A))

  ;; ALWAYS:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; ALWAYS:      (type $none_=>_none (func))

  ;; ALWAYS:      (type $ref|$B|_=>_none (func (param (ref $B))))

  ;; ALWAYS:      (import "a" "b" (func $import (param (ref $A))))
  ;; CAREFUL:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; CAREFUL:      (type $none_=>_none (func))

  ;; CAREFUL:      (import "a" "b" (func $import (param (ref $A))))
  (import "a" "b" (func $import (param (ref $A))))

  ;; ALWAYS:      (func $calls (type $none_=>_none)
  ;; ALWAYS-NEXT:  (call $refinable
  ;; ALWAYS-NEXT:   (struct.new_default $A)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $refinable
  ;; ALWAYS-NEXT:   (struct.new_default $A)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $refinable_0
  ;; ALWAYS-NEXT:   (struct.new_default $B)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $refinable_0
  ;; ALWAYS-NEXT:   (struct.new_default $B)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $calls (type $none_=>_none)
  ;; CAREFUL-NEXT:  (call $refinable
  ;; CAREFUL-NEXT:   (struct.new_default $A)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $refinable
  ;; CAREFUL-NEXT:   (struct.new_default $A)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $refinable
  ;; CAREFUL-NEXT:   (struct.new_default $B)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $refinable
  ;; CAREFUL-NEXT:   (struct.new_default $B)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT: )
  (func $calls
    ;; Two calls with $A, two with $B. The calls to $B should both go to the
    ;; same new function which has a refined parameter of $B.
    ;;
    ;; However, in CAREFUL mode we won't do that, as there is no helpful
    ;; improvement in the target functions even with the refined types.
    (call $refinable
      (struct.new $A)
    )
    (call $refinable
      (struct.new $A)
    )
    (call $refinable
      (struct.new $B)
    )
    (call $refinable
      (struct.new $B)
    )
  )

  ;; ALWAYS:      (func $call-import (type $none_=>_none)
  ;; ALWAYS-NEXT:  (call $import
  ;; ALWAYS-NEXT:   (struct.new_default $B)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $call-import (type $none_=>_none)
  ;; CAREFUL-NEXT:  (call $import
  ;; CAREFUL-NEXT:   (struct.new_default $B)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT: )
  (func $call-import
    ;; Calls to imports are left as they are.
    (call $import
      (struct.new $B)
    )
  )

  ;; ALWAYS:      (func $refinable (type $ref|$A|_=>_none) (param $ref (ref $A))
  ;; ALWAYS-NEXT:  (drop
  ;; ALWAYS-NEXT:   (local.get $ref)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $refinable (type $ref|$A|_=>_none) (param $0 (ref $A))
  ;; CAREFUL-NEXT:  (nop)
  ;; CAREFUL-NEXT: )
  (func $refinable (param $ref (ref $A))
    ;; Helper function for the above. Use the parameter to see we update types
    ;; etc when we make a refined version of the function (if we didn't,
    ;; validation would error).
    ;;
    ;; In CAREFUL mode we optimize to check if refined types help, which has the
    ;; side effect of optimizing the body of this function into a nop.
    (drop
      (local.get $ref)
    )
  )
)


;; ALWAYS:      (func $refinable_0 (type $ref|$B|_=>_none) (param $ref (ref $B))
;; ALWAYS-NEXT:  (drop
;; ALWAYS-NEXT:   (local.get $ref)
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT: )
(module
  ;; As above, but now the refinable function uses the local in a way that
  ;; requires a fixup.

  ;; ALWAYS:      (type $A (struct ))
  ;; CAREFUL:      (type $none_=>_none (func))

  ;; CAREFUL:      (type $A (struct ))
  (type $A (struct_subtype data))
  ;; ALWAYS:      (type $B (struct_subtype  $A))
  ;; CAREFUL:      (type $B (struct_subtype  $A))
  (type $B (struct_subtype $A))



  ;; ALWAYS:      (type $none_=>_none (func))

  ;; ALWAYS:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; ALWAYS:      (type $ref|$B|_=>_none (func (param (ref $B))))

  ;; ALWAYS:      (func $calls (type $none_=>_none)
  ;; ALWAYS-NEXT:  (call $refinable_0
  ;; ALWAYS-NEXT:   (struct.new_default $B)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; CAREFUL:      (func $calls (type $none_=>_none)
  ;; CAREFUL-NEXT:  (call $refinable
  ;; CAREFUL-NEXT:   (struct.new_default $B)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT: )
  (func $calls
    (call $refinable
      (struct.new $B)
    )
  )

  ;; ALWAYS:      (func $refinable (type $ref|$A|_=>_none) (param $ref (ref $A))
  ;; ALWAYS-NEXT:  (local $unref (ref $A))
  ;; ALWAYS-NEXT:  (local.set $unref
  ;; ALWAYS-NEXT:   (local.get $ref)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (local.set $ref
  ;; ALWAYS-NEXT:   (local.get $unref)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $refinable (type $ref|$A|_=>_none) (param $0 (ref $A))
  ;; CAREFUL-NEXT:  (nop)
  ;; CAREFUL-NEXT: )
  (func $refinable (param $ref (ref $A))
    (local $unref (ref $A))
    (local.set $unref
      (local.get $ref)
    )
    ;; If we refine $ref then this set will be invalid - we'd be setting a less-
    ;; refined type into a local/param that is more refined. We should fix this
    ;; up by using a temp local.
    (local.set $ref
      (local.get $unref)
    )
  )
)


;; ALWAYS:      (func $refinable_0 (type $ref|$B|_=>_none) (param $ref (ref $B))
;; ALWAYS-NEXT:  (local $unref (ref $A))
;; ALWAYS-NEXT:  (local $2 (ref $A))
;; ALWAYS-NEXT:  (local.set $2
;; ALWAYS-NEXT:   (local.get $ref)
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT:  (block
;; ALWAYS-NEXT:   (local.set $unref
;; ALWAYS-NEXT:    (local.get $2)
;; ALWAYS-NEXT:   )
;; ALWAYS-NEXT:   (local.set $2
;; ALWAYS-NEXT:    (local.get $unref)
;; ALWAYS-NEXT:   )
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT: )
(module
  ;; Multiple refinings of the same function, and of different functions.

  ;; ALWAYS:      (type $A (struct ))
  ;; CAREFUL:      (type $none_=>_none (func))

  ;; CAREFUL:      (type $A (struct ))
  (type $A (struct_subtype data))
  ;; ALWAYS:      (type $B (struct_subtype  $A))
  ;; CAREFUL:      (type $B (struct_subtype  $A))
  (type $B (struct_subtype $A))

  ;; ALWAYS:      (type $none_=>_none (func))

  ;; ALWAYS:      (type $C (struct_subtype  $B))
  ;; CAREFUL:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; CAREFUL:      (type $C (struct_subtype  $B))
  (type $C (struct_subtype $B))

  ;; ALWAYS:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; ALWAYS:      (type $ref|$B|_=>_none (func (param (ref $B))))

  ;; ALWAYS:      (type $ref|$C|_=>_none (func (param (ref $C))))

  ;; ALWAYS:      (func $calls1 (type $none_=>_none)
  ;; ALWAYS-NEXT:  (call $refinable1
  ;; ALWAYS-NEXT:   (struct.new_default $A)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $refinable1_0
  ;; ALWAYS-NEXT:   (struct.new_default $B)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $calls1 (type $none_=>_none)
  ;; CAREFUL-NEXT:  (call $refinable1
  ;; CAREFUL-NEXT:   (struct.new_default $A)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $refinable1
  ;; CAREFUL-NEXT:   (struct.new_default $B)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT: )
  (func $calls1
    (call $refinable1
      (struct.new $A)
    )
    (call $refinable1
      (struct.new $B)
    )
  )

  ;; ALWAYS:      (func $calls2 (type $none_=>_none)
  ;; ALWAYS-NEXT:  (call $refinable1_1
  ;; ALWAYS-NEXT:   (struct.new_default $C)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $refinable2_0
  ;; ALWAYS-NEXT:   (struct.new_default $B)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $calls2 (type $none_=>_none)
  ;; CAREFUL-NEXT:  (call $refinable1
  ;; CAREFUL-NEXT:   (struct.new_default $C)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $refinable2
  ;; CAREFUL-NEXT:   (struct.new_default $B)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT: )
  (func $calls2
    (call $refinable1
      (struct.new $C)
    )
    (call $refinable2
      (struct.new $B)
    )
  )

  ;; ALWAYS:      (func $refinable1 (type $ref|$A|_=>_none) (param $ref (ref $A))
  ;; ALWAYS-NEXT:  (drop
  ;; ALWAYS-NEXT:   (local.get $ref)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $refinable1 (type $ref|$A|_=>_none) (param $0 (ref $A))
  ;; CAREFUL-NEXT:  (nop)
  ;; CAREFUL-NEXT: )
  (func $refinable1 (param $ref (ref $A))
    (drop
      (local.get $ref)
    )
  )

  ;; ALWAYS:      (func $refinable2 (type $ref|$A|_=>_none) (param $ref (ref $A))
  ;; ALWAYS-NEXT:  (drop
  ;; ALWAYS-NEXT:   (local.get $ref)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $refinable2 (type $ref|$A|_=>_none) (param $0 (ref $A))
  ;; CAREFUL-NEXT:  (nop)
  ;; CAREFUL-NEXT: )
  (func $refinable2 (param $ref (ref $A))
    (drop
      (local.get $ref)
    )
  )
)

;; ALWAYS:      (func $refinable1_0 (type $ref|$B|_=>_none) (param $ref (ref $B))
;; ALWAYS-NEXT:  (drop
;; ALWAYS-NEXT:   (local.get $ref)
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT: )

;; ALWAYS:      (func $refinable1_1 (type $ref|$C|_=>_none) (param $ref (ref $C))
;; ALWAYS-NEXT:  (drop
;; ALWAYS-NEXT:   (local.get $ref)
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT: )

;; ALWAYS:      (func $refinable2_0 (type $ref|$B|_=>_none) (param $ref (ref $B))
;; ALWAYS-NEXT:  (drop
;; ALWAYS-NEXT:   (local.get $ref)
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT: )
(module
  ;; A case where even CAREFUL mode will monomorphize, as it helps the target
  ;; function get optimized better.

  ;; ALWAYS:      (type $A (struct ))
  ;; CAREFUL:      (type $A (struct ))
  (type $A (struct_subtype data))

  ;; ALWAYS:      (type $B (struct_subtype  $A))
  ;; CAREFUL:      (type $B (struct_subtype  $A))
  (type $B (struct_subtype $A))

  ;; ALWAYS:      (type $ref|$B|_=>_none (func (param (ref $B))))

  ;; ALWAYS:      (type $none_=>_none (func))

  ;; ALWAYS:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; ALWAYS:      (import "a" "b" (func $import (param (ref $B))))

  ;; ALWAYS:      (global $global (mut i32) (i32.const 1))
  ;; CAREFUL:      (type $ref|$B|_=>_none (func (param (ref $B))))

  ;; CAREFUL:      (type $none_=>_none (func))

  ;; CAREFUL:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; CAREFUL:      (import "a" "b" (func $import (param (ref $B))))

  ;; CAREFUL:      (global $global (mut i32) (i32.const 1))
  (global $global (mut i32) (i32.const 1))

  (import "a" "b" (func $import (param (ref $B))))

  ;; ALWAYS:      (func $calls (type $none_=>_none)
  ;; ALWAYS-NEXT:  (call $refinable
  ;; ALWAYS-NEXT:   (struct.new_default $A)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $refinable
  ;; ALWAYS-NEXT:   (struct.new_default $A)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $refinable_0
  ;; ALWAYS-NEXT:   (struct.new_default $B)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $refinable_0
  ;; ALWAYS-NEXT:   (struct.new_default $B)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $calls (type $none_=>_none)
  ;; CAREFUL-NEXT:  (call $refinable
  ;; CAREFUL-NEXT:   (struct.new_default $A)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $refinable
  ;; CAREFUL-NEXT:   (struct.new_default $A)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $refinable_0
  ;; CAREFUL-NEXT:   (struct.new_default $B)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $refinable_0
  ;; CAREFUL-NEXT:   (struct.new_default $B)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT: )
  (func $calls
    ;; The calls sending $B will switch to calling a refined version, as the
    ;; refined version is better, even in CAREFUL mode.
    (call $refinable
      (struct.new $A)
    )
    (call $refinable
      (struct.new $A)
    )
    (call $refinable
      (struct.new $B)
    )
    (call $refinable
      (struct.new $B)
    )
  )

  ;; ALWAYS:      (func $refinable (type $ref|$A|_=>_none) (param $ref (ref $A))
  ;; ALWAYS-NEXT:  (local $x (ref $A))
  ;; ALWAYS-NEXT:  (call $import
  ;; ALWAYS-NEXT:   (ref.cast null $B
  ;; ALWAYS-NEXT:    (local.get $ref)
  ;; ALWAYS-NEXT:   )
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (local.set $x
  ;; ALWAYS-NEXT:   (select (result (ref $A))
  ;; ALWAYS-NEXT:    (local.get $ref)
  ;; ALWAYS-NEXT:    (struct.new_default $B)
  ;; ALWAYS-NEXT:    (global.get $global)
  ;; ALWAYS-NEXT:   )
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $import
  ;; ALWAYS-NEXT:   (ref.cast null $B
  ;; ALWAYS-NEXT:    (local.get $x)
  ;; ALWAYS-NEXT:   )
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $import
  ;; ALWAYS-NEXT:   (ref.cast null $B
  ;; ALWAYS-NEXT:    (local.get $x)
  ;; ALWAYS-NEXT:   )
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT:  (call $import
  ;; ALWAYS-NEXT:   (ref.cast null $B
  ;; ALWAYS-NEXT:    (local.get $ref)
  ;; ALWAYS-NEXT:   )
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $refinable (type $ref|$A|_=>_none) (param $0 (ref $A))
  ;; CAREFUL-NEXT:  (local $1 (ref $A))
  ;; CAREFUL-NEXT:  (call $import
  ;; CAREFUL-NEXT:   (ref.cast null $B
  ;; CAREFUL-NEXT:    (local.get $0)
  ;; CAREFUL-NEXT:   )
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $import
  ;; CAREFUL-NEXT:   (ref.cast null $B
  ;; CAREFUL-NEXT:    (local.tee $1
  ;; CAREFUL-NEXT:     (select (result (ref $A))
  ;; CAREFUL-NEXT:      (local.get $0)
  ;; CAREFUL-NEXT:      (struct.new_default $B)
  ;; CAREFUL-NEXT:      (global.get $global)
  ;; CAREFUL-NEXT:     )
  ;; CAREFUL-NEXT:    )
  ;; CAREFUL-NEXT:   )
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $import
  ;; CAREFUL-NEXT:   (ref.cast null $B
  ;; CAREFUL-NEXT:    (local.get $1)
  ;; CAREFUL-NEXT:   )
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT:  (call $import
  ;; CAREFUL-NEXT:   (ref.cast null $B
  ;; CAREFUL-NEXT:    (local.get $0)
  ;; CAREFUL-NEXT:   )
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT: )
  (func $refinable (param $ref (ref $A))
    (local $x (ref $A))
    ;; The refined version of this function will not have the cast, since
    ;; optimizations manage to remove it using the more refined type.
    ;;
    ;; (That is the case in CAREFUL mode, which optimizes; in ALWAYS mode the
    ;; cast will remain since we monomorphize without bothering to optimize and
    ;; see if there is any benefit.)
    (call $import
      (ref.cast null $B
        (local.get $ref)
      )
    )
    ;; Also copy the param into a local. The local should get refined to $B in
    ;; the refined function in CAREFUL mode.
    (local.set $x
      ;; Use a select here so optimizations don't just merge $x and $ref.
      (select (result (ref $A))
        (local.get $ref)
        (struct.new $B)
        (global.get $global)
      )
    )
    (call $import
      (ref.cast null $B
        (local.get $x)
      )
    )
    (call $import
      (ref.cast null $B
        (local.get $x)
      )
    )
    ;; Another use of $ref, also to avoid opts merging $x and $ref.
    (call $import
      (ref.cast null $B
        (local.get $ref)
      )
    )
  )
)

;; ALWAYS:      (func $refinable_0 (type $ref|$B|_=>_none) (param $ref (ref $B))
;; ALWAYS-NEXT:  (local $x (ref $A))
;; ALWAYS-NEXT:  (call $import
;; ALWAYS-NEXT:   (ref.cast null $B
;; ALWAYS-NEXT:    (local.get $ref)
;; ALWAYS-NEXT:   )
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT:  (local.set $x
;; ALWAYS-NEXT:   (select (result (ref $B))
;; ALWAYS-NEXT:    (local.get $ref)
;; ALWAYS-NEXT:    (struct.new_default $B)
;; ALWAYS-NEXT:    (global.get $global)
;; ALWAYS-NEXT:   )
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT:  (call $import
;; ALWAYS-NEXT:   (ref.cast null $B
;; ALWAYS-NEXT:    (local.get $x)
;; ALWAYS-NEXT:   )
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT:  (call $import
;; ALWAYS-NEXT:   (ref.cast null $B
;; ALWAYS-NEXT:    (local.get $x)
;; ALWAYS-NEXT:   )
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT:  (call $import
;; ALWAYS-NEXT:   (ref.cast null $B
;; ALWAYS-NEXT:    (local.get $ref)
;; ALWAYS-NEXT:   )
;; ALWAYS-NEXT:  )
;; ALWAYS-NEXT: )

;; CAREFUL:      (func $refinable_0 (type $ref|$B|_=>_none) (param $0 (ref $B))
;; CAREFUL-NEXT:  (local $1 (ref $B))
;; CAREFUL-NEXT:  (call $import
;; CAREFUL-NEXT:   (local.get $0)
;; CAREFUL-NEXT:  )
;; CAREFUL-NEXT:  (call $import
;; CAREFUL-NEXT:   (local.tee $1
;; CAREFUL-NEXT:    (select (result (ref $B))
;; CAREFUL-NEXT:     (local.get $0)
;; CAREFUL-NEXT:     (struct.new_default $B)
;; CAREFUL-NEXT:     (global.get $global)
;; CAREFUL-NEXT:    )
;; CAREFUL-NEXT:   )
;; CAREFUL-NEXT:  )
;; CAREFUL-NEXT:  (call $import
;; CAREFUL-NEXT:   (local.get $1)
;; CAREFUL-NEXT:  )
;; CAREFUL-NEXT:  (call $import
;; CAREFUL-NEXT:   (local.get $0)
;; CAREFUL-NEXT:  )
;; CAREFUL-NEXT: )
(module
  ;; Test that we avoid recursive calls.

  ;; ALWAYS:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; ALWAYS:      (type $A (struct ))
  ;; CAREFUL:      (type $ref|$A|_=>_none (func (param (ref $A))))

  ;; CAREFUL:      (type $A (struct ))
  (type $A (struct_subtype data))
  ;; ALWAYS:      (type $B (struct_subtype  $A))
  ;; CAREFUL:      (type $B (struct_subtype  $A))
  (type $B (struct_subtype $A))


  ;; ALWAYS:      (func $calls (type $ref|$A|_=>_none) (param $ref (ref $A))
  ;; ALWAYS-NEXT:  (call $calls
  ;; ALWAYS-NEXT:   (struct.new_default $B)
  ;; ALWAYS-NEXT:  )
  ;; ALWAYS-NEXT: )
  ;; CAREFUL:      (func $calls (type $ref|$A|_=>_none) (param $ref (ref $A))
  ;; CAREFUL-NEXT:  (call $calls
  ;; CAREFUL-NEXT:   (struct.new_default $B)
  ;; CAREFUL-NEXT:  )
  ;; CAREFUL-NEXT: )
  (func $calls (param $ref (ref $A))
    ;; We should change nothing in this recursive call, even though we are
    ;; sending a more refined type, so we could try to monomorphize in theory.
    (call $calls
      (struct.new $B)
    )
  )
)
