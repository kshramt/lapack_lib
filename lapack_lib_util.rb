require 'fort'

def promote(a, b)
  ta = a.type
  tb = b.type
  ka = a.kind
  kb = b.kind
  t = promote_type(ta, tb)
  if ta == :Integer and tb == :Integer
    [t, promote_kind(ka, kb)]
  elsif ta == :Integer
    [t, kb]
  elsif tb == :Integer
    [t, ka]
  else
    [t, promote_kind(ka, kb)]
  end
end


NUMERIC_TOWER = [:Integer, :Real, :Complex]
def promote_type(ta, tb)
  if ta == :Logical && tb == :Logical
    :Logical
  else
    ita = NUMERIC_TOWER.index(ta)
    itb = NUMERIC_TOWER.index(tb)
    NUMERIC_TOWER[[ita, itb].max]
  end
end

REAL_KINDS = [:REAL32, :REAL64, :REAL128]
INTEGER_KINDS = [:INT8, :INT16, :INT32, :INT64, :INT128]
def promote_kind(ka, kb)
  if (ika = REAL_KINDS.index(ka)) && (ikb = REAL_KINDS.index(kb))
    REAL_KINDS[[ika, ikb].max]
  elsif (ika = INTEGER_KINDS.index(ka)) && (ikb = INTEGER_KINDS.index(kb))
    INTEGER_KINDS[[ika, ikb].max]
  else
    raise "Unknown kind: #{ka}, #{kb}"
  end
end

def declare(a, b)
  _declare(*promote(a, b), dim(a.dim, b.dim))
end

def _declare(t, k, d)
  "#{t}(kind=#{k})#{d}"
end

DIMS_TO_DECLARE = {
  [0, 0] => '',
  [0, 1] => ", dimension(size(b, 1, kind=SIZE_KIND))",
  [0, 2] => ", dimension(size(b, 1, kind=SIZE_KIND), size(b, 2, kind=SIZE_KIND))",
  [1, 0] => ", dimension(size(a, 1, kind=SIZE_KIND))",
  [1, 1] => '',
  [1, 2] => ", dimension(size(b, 2, kind=SIZE_KIND))",
  [2, 0] => ", dimension(size(a, 1, kind=SIZE_KIND), size(a, 2, kind=SIZE_KIND))",
  [2, 1] => ", dimension(size(a, 1, kind=SIZE_KIND))",
  [2, 2] => ", dimension(size(a, 1, kind=SIZE_KIND), size(b, 2, kind=SIZE_KIND))",
}
def dim(da, db)
  DIMS_TO_DECLARE.fetch([da, db])
end

def declare_sizes(a, b)
  ns = ((1..a.dim).map{|d| "n_a_#{d}"} + (1..b.dim).map{|d| "n_b_#{d}"})
  if ns.size > 0
    "Integer(kind=SIZE_KIND):: " + ns.join(', ')
  else
    ''
  end
end

def set_sizes(a, b)
  es = ((1..a.dim).map{|d| "n_a_#{d} = size(a, #{d}, kind=SIZE_KIND)"} + (1..b.dim).map{|d| "n_b_#{d} = size(b, #{d}, kind=SIZE_KIND)"})
  if es.size > 0
    es.join('; ')
  else
    ''
  end
end


def prod2(xs)
  xs.product(xs)
end

def fassert(s)
#  "if(.not.(#{s}))then; write(ERROR_UNIT, *) \"RAISE: \", __FILE__, ' ', __LINE__, \".not.(#{s})\"; error stop; else; write(ERROR_UNIT, *) n_a_1, n_b_1; end if"
  "if(.not.(#{s}))then; call raise(__FILE__, __LINE__, \".not.(#{s})\"); end if"
end

def converter(t)
  {
    Real: :real,
    Integer: :int,
    Complex: :cmplx,
  }.fetch(t)
end

REAL0S = ::Fort::Type::Real.multi_provide(dim: 0)
REAL1S = ::Fort::Type::Real.multi_provide(dim: 1)
REAL2S = ::Fort::Type::Real.multi_provide(dim: 2)
INTEGER0S = ::Fort::Type::Integer.multi_provide(dim: 0)
INTEGER1S = ::Fort::Type::Integer.multi_provide(dim: 1)
INTEGER2S = ::Fort::Type::Integer.multi_provide(dim: 2)
COMPLEX0S = ::Fort::Type::Complex.multi_provide(dim: 0)
COMPLEX1S = ::Fort::Type::Complex.multi_provide(dim: 1)
COMPLEX2S = ::Fort::Type::Complex.multi_provide(dim: 2)
LOGICAL0S = ::Fort::Type::Logical.multi_provide(dim: 0)
LOGICAL1S = ::Fort::Type::Logical.multi_provide(dim: 1)
LOGICAL2S = ::Fort::Type::Logical.multi_provide(dim: 2)
NUM0S = REAL0S + INTEGER0S + COMPLEX0S
NUM1S = REAL1S + INTEGER1S + COMPLEX1S
NUM2S = REAL2S + INTEGER2S + COMPLEX2S

NUM_SCALAR = prod2(NUM0S)
LOGICAL_SCALAR = prod2(LOGICAL0S)
NUM_SCALAR_MUL_VEC_OR_MAT = NUM0S.product(NUM1S + NUM2S) + (NUM1S + NUM2S).product(NUM0S)
LOGICAL_SCALAR_MUL_VEC_OR_MAT = LOGICAL0S.product(LOGICAL1S + LOGICAL2S) + (LOGICAL1S + LOGICAL2S).product(LOGICAL0S)
VEC_VEC = prod2(NUM1S) + prod2(LOGICAL1S)
MAT_VEC_OR_MAT = prod2(NUM2S) + NUM2S.product(NUM1S) + NUM1S.product(NUM2S) + prod2(LOGICAL2S) + LOGICAL2S.product(LOGICAL1S) + LOGICAL1S.product(LOGICAL2S)

TYPES = NUM_SCALAR + LOGICAL_SCALAR + NUM_SCALAR_MUL_VEC_OR_MAT + LOGICAL_SCALAR_MUL_VEC_OR_MAT + VEC_VEC + MAT_VEC_OR_MAT


if __FILE__ == $PROGRAM_NAME
  p promote_kind(:REAL32, :REAL128) == :REAL128
end
