module IntAvltree = Obatcher_ds.Avlgeneral.Sequential(Int);;
module IntAvltreePrebatch = Obatcher_ds.Avlgeneral.Prebatch(Int);;
module IntAvltreeSplitJoin = Obatcher_ds.Splitjoin.Make(IntAvltreePrebatch);;

let num_nodes = 10000000;;
let max_key = num_nodes;;
let num_pivots = 10000;;

Printf.printf "\nStarting split test for AVL trees...\n";;

let at = IntAvltree.init ();;
let ref_array_2 = Array.make max_key @@ -1;;

let st = Sys.time();;
let () = for _ = 1 to num_nodes do
  let k = Random.full_int max_key in
  let v = Random.full_int max_key in
  IntAvltree.insert k v at;
  if ref_array_2.(k) == -1 then ref_array_2.(k) <- v
done;;

Printf.printf "Insertion time for AVL tree: %fs\n" (Sys.time() -. st);;

let st = Sys.time();;
assert (IntAvltree.verify_height_invariant at.root);;
let () = for i = 0 to max_key - 1 do
  if ref_array_2.(i) != -1 then
    assert (IntAvltree.search i at = Some ref_array_2.(i))
  else assert (IntAvltree.search i at = None)
done;;
Printf.printf "Verification time for AVL tree: %fs\n" (Sys.time() -. st);;

let pivot_arr = Array.init num_pivots (fun _ -> Random.full_int max_key);;
Array.sort Int.compare pivot_arr;;

let st = Sys.time();;
let split_arr = IntAvltreePrebatch.split pivot_arr at;;
Printf.printf "Split time for AVL tree: %fs\n" (Sys.time() -. st);;

Printf.printf "%d\n" (Array.length pivot_arr);;
Printf.printf "%d\n" (Array.length split_arr);;
assert(Array.length split_arr = num_pivots + 1);;
let cur_pivot_idx = ref 0;;
let st = Sys.time();;
let () = for i = 0 to max_key - 1 do
  while !cur_pivot_idx < Array.length pivot_arr && pivot_arr.(!cur_pivot_idx) = i do
    cur_pivot_idx := !cur_pivot_idx + 1;
  done;
  if ref_array_2.(i) != -1 then
    assert (IntAvltree.search i split_arr.(!cur_pivot_idx) = Some ref_array_2.(i))
  else assert (IntAvltree.search i split_arr.(!cur_pivot_idx) = None)
done;;
Printf.printf "Verification time for split AVL tree: %fs\n" (Sys.time() -. st);;