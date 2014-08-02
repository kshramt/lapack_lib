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
def promote_type(t1, t2)
  if t1 == :Logical && t2 == :Logical
    :Logical
  else
    it1 = NUMERIC_TOWER.index(t1)
    it2 = NUMERIC_TOWER.index(t2)
    NUMERIC_TOWER[[it1, it2].max]
  end
end

REAL_KINDS = [:REAL32, :REAL64, :REAL128]
INTEGER_KINDS = [:INT8, :INT16, :INT32, :INT64, :INT128]
def promote_kind(k1, k2)
  if (ik1 = REAL_KINDS.index(k1)) && (ik2 = REAL_KINDS.index(k2))
    REAL_KINDS[[ik1, ik2].max]
  elsif (ik1 = INTEGER_KINDS.index(k1)) && (ik2 = INTEGER_KINDS.index(k2))
    INTEGER_KINDS[[ik1, ik2].max]
  else
    raise "Unknown kind: #{k1}, #{k2}"
  end
end

def declare(t1, t2)
  _declare(*promote(t1, t2), dim(t1.dim, t2.dim))
end

def _declare(t, k, d)
  "#{t}(kind=#{k})#{d}"
end

def dim(d1, d2)
  if d1 == 0 && d2 == 0
    ''
  elsif d1 == 0 && d2 == 1
    ", dimension(lbound(b, 1):ubound(b, 1))"
  elsif d1 == 0 && d2 == 2
    ", dimension(lbound(b, 1):ubound(b, 1), lbound(b, 2):ubound(b, 2))"
  elsif d1 == 1 && d2 == 0
    ", dimension(lbound(a, 1):ubound(a, 1))"
  elsif d1 == 1 && d2 == 1
    ''
  elsif d1 == 1 && d2 == 2
    ", dimension(lbound(b, 2):ubound(b, 2))"
  elsif d1 == 2 && d2 == 0
    ", dimension(lbound(a, 1):ubound(a, 1), lbound(a, 2):ubound(a, 2))"
  elsif d1 == 2 && d2 == 1
    ", dimension(lbound(a, 1):ubound(a, 1))"
  elsif d1 == 2 && d2 == 2
    ", dimension(lbound(a, 1):ubound(a, 1), lbound(b, 2):ubound(b, 2))"
  else
    raise "MUST NOT HAPPEN"
  end
end

if __FILE__ == $PROGRAM_NAME
  p promote_kind(:REAL32, :REAL128) == :REAL128
end
