require "z3"

rx, ry, rz = Z3.Int('rx'), Z3.Int('ry'), Z3.Int('rz')
rvx, rvy, rvz = Z3.Int('rvx'), Z3.Int('rvy'), Z3.Int('rvz')
t0, t1, t2 = Z3.Int('t0'), Z3.Int('t1'), Z3.Int('t2')
answer = Z3.Int('answer')

solver = Z3::Solver.new

solver.assert(rx + t0 * rvx == 294040563055029 + t0 * -14)
solver.assert(ry + t0 * rvy == 390459835311429 + t0 * -33)
solver.assert(rz + t0 * rvz == 430929964653284 + t0 * -136)

solver.assert(rx + t1 * rvx == 277956000745130 + t1 * 9)
solver.assert(ry + t1 * rvy == 354560401734564 + t1 * -36)
solver.assert(rz + t1 * rvz == 304340564999986 + t1 * 14)

solver.assert(rx + t2 * rvx == 167135982400842 + t2 * 128)
solver.assert(ry + t2 * rvy == 222756086467026 + t2 * 197)
solver.assert(rz + t2 * rvz == 67877440945953  + t2 * 296)

solver.assert(answer == rx + ry + rz)

if solver.satisfiable?
  model = solver.model
  puts "Answer is: #{model[Z3.Int('answer')]}"
end
