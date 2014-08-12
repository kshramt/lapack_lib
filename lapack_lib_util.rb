require 'minitest'
require 'minitest/unit'

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
  elsif ta == :Logical or tb == :Logical
    raise "Not promotable: #{ta}, #{tb}"
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

def declare12(a, b, ntcb)
  t, k = promote(a, b)
  d = ntcb == :n ? 2 : 1
  "#{t}(kind=#{k}), dimension(size(b, #{d}, kind=SIZE_KIND))"
end

def declare21(a, b, ntca)
  t, k = promote(a, b)
  d = ntca == :n ? 1 : 2
  "#{t}(kind=#{k}), dimension(size(a, #{d}, kind=SIZE_KIND))"
end

def declare22(a, b, ntca, ntcb)
  t, k = promote(a, b)
  d1 = ntca == :n ? 1 : 2
  d2 = ntcb == :n ? 2 : 1
  "#{t}(kind=#{k}), dimension(size(a, #{d1}, kind=SIZE_KIND), size(b, #{d2}, kind=SIZE_KIND))"
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
  [2, 0] => ", dimension(size(a, 1, kind=SIZE_KIND), size(a, 2, kind=SIZE_KIND))",
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


def ntc_type_from_mode(mode)
  {
    n: :TransN,
    t: :TransT,
    c: :TransC,
  }.fetch(mode)
end


def gen_ntc(t)
  if t.type == :Complex
    [:n, :t, :c]
  else
    [:n, :t]
  end
end

def ntc_fn(mode, arg)
  case mode
  when :n
    arg
  when :t
    "transpose(#{arg})"
  when :c
    "transpose(conjg(#{arg}))"
  else
    raise "Unknown mode: #{mode}"
  end
end

def prod2(xs)
  xs.product(xs)
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

TYPES =
  (LOGICAL0S_LOGICAL0S = LOGICAL0S.product(LOGICAL0S)) + # scalar logical
  (LOGICAL0S_LOGICAL12S = LOGICAL0S.product(LOGICAL1S + LOGICAL2S)) +
  (LOGICAL12S_LOGICAL0S = (LOGICAL1S + LOGICAL2S).product(LOGICAL0S)) +
  (NUM0S_NUM0S = NUM0S.product(NUM0S)) + # sucalar numeric
  (NUM0S_NUM12S = NUM0S.product(NUM1S + NUM2S)) +
  (NUM12S_NUM0S = (NUM1S + NUM2S).product(NUM0S)) +
  (NUM1S_NUM1S = NUM1S.product(NUM1S)) + # vector vector
  (LOGICAL1S_LOGICAL1S = LOGICAL1S.product(LOGICAL1S)) +
  (LOGICAL1S_LOGICAL2S = LOGICAL1S.product(LOGICAL2S)) + # vector matrix
  (NUM1S_NUM2S = NUM1S.product(NUM2S)) +
  (LOGICAL2S_LOGICAL1S = LOGICAL2S.product(LOGICAL1S)) + # matrix vector
  (NUM2S_NUM1S = NUM2S.product(NUM1S)) +
  (LOGICAL2S_LOGICAL2S = LOGICAL2S.product(LOGICAL2S)) + # matrix matrix
  (NUM2S_NUM2S = NUM2S.product(NUM2S))

T1S_U2S = LOGICAL1S_LOGICAL2S + NUM1S_NUM2S
T1S_U2S_NTCS = T1S_U2S.map{|a, b| [a, b, gen_ntc(b)]}
T2S_U1S = LOGICAL2S_LOGICAL1S + NUM2S_NUM1S
T2S_U1S_NTCS = T2S_U1S.map{|a, b| [a, b, gen_ntc(a)]}
T2S_U2S = LOGICAL2S_LOGICAL2S + NUM2S_NUM2S
T2S_U2S_NTCS = T2S_U2S.map{|a, b| [a, b, gen_ntc(a).product(gen_ntc(b))]}


class Tester < MiniTest::Test
  def test_prmote_kind
    assert_equal promote_kind(:REAL32, :REAL32), :REAL32
    assert_equal promote_kind(:REAL32, :REAL64), :REAL64
    assert_equal promote_kind(:REAL32, :REAL128), :REAL128
    assert_equal promote_kind(:REAL64, :REAL32), :REAL64
    assert_equal promote_kind(:REAL64, :REAL64), :REAL64
    assert_equal promote_kind(:REAL64, :REAL128), :REAL128
    assert_equal promote_kind(:REAL128, :REAL32), :REAL128
    assert_equal promote_kind(:REAL128, :REAL64), :REAL128
    assert_equal promote_kind(:REAL128, :REAL128), :REAL128
    assert_equal promote_kind(:INT32, :INT32), :INT32
    assert_equal promote_kind(:INT32, :INT64), :INT64
    assert_equal promote_kind(:INT32, :INT16), :INT32
    assert_equal promote_kind(:INT64, :INT32), :INT64
    assert_equal promote_kind(:INT64, :INT64), :INT64
    assert_equal promote_kind(:INT64, :INT16), :INT64
    assert_equal promote_kind(:INT16, :INT32), :INT32
    assert_equal promote_kind(:INT16, :INT64), :INT64
    assert_equal promote_kind(:INT16, :INT16), :INT16
    assert_raises RuntimeError do
      promote_kind(:INT32, :REAL32)
    end
  end

  def test_promote_type
    assert_equal promote_type(:Integer, :Integer), :Integer
    assert_equal promote_type(:Integer, :Real), :Real
    assert_equal promote_type(:Integer, :Complex), :Complex
    assert_equal promote_type(:Real, :Integer), :Real
    assert_equal promote_type(:Real, :Real), :Real
    assert_equal promote_type(:Real, :Complex), :Complex
    assert_equal promote_type(:Complex, :Integer), :Complex
    assert_equal promote_type(:Complex, :Real), :Complex
    assert_equal promote_type(:Complex, :Complex), :Complex
    assert_equal promote_type(:Logical, :Logical), :Logical
    assert_raises RuntimeError do
      promote_type(:Logical, :Integer)
    end
    assert_raises RuntimeError do
      promote_type(:Logical, :Real)
    end
    assert_raises RuntimeError do
      promote_type(:Logical, :Complex)
    end
    assert_raises RuntimeError do
      promote_type(:Integer, :Logical)
    end
    assert_raises RuntimeError do
      promote_type(:Real, :Logical)
    end
    assert_raises RuntimeError do
      promote_type(:Complex, :Logical)
    end
  end
end



if __FILE__ == $PROGRAM_NAME
  MiniTest.run()
end
