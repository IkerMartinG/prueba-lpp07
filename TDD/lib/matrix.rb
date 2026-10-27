# TDD/lib/matrix.rb
require 'timeout'

module MatrixOperations
  def self.add(m1, m2)
    raise ArgumentError, "Tamaños incompatibles" if m1.size != m2.size
    n = m1.size
    res = Array.new(n) { Array.new(n, 0) }
    for i in 0...n
      for j in 0...n
        res[i][j] = m1[i][j] + m2[i][j]
      end
    end
    res
  end

  def self.scalar_product(m, scalar)
    n = m.size
    res = Array.new(n) { Array.new(n, 0) }
    for i in 0...n
      for j in 0...n
        res[i][j] = m[i][j] * scalar
      end
    end
    res
  end

  def self.transpose(m)
    n = m.size
    res = Array.new(n) { Array.new(n, 0) }
    for i in 0...n
      for j in 0...n
        res[i][j] = m[j][i]
      end
    end
    res
  end

  def self.configurable_concurrent(m1, m2, scalar, options = {})
    operations = options[:operations] || [:add]
    timeout_val = options[:timeout] || 5
    results = {}

    threads = []
    for op in operations
      threads << Thread.new(op) do |current_op|
        begin
          ::Timeout.timeout(timeout_val) do
            val = case current_op
                  when :add
                    add(m1, m2)
                  when :scalar_product
                    scalar_product(m1, scalar)
                  when :transpose
                    transpose(m1)
                  when :slow_op
                    sleep(1)
                    add(m1, m2)
                  else
                    raise "Operación desconocida"
                  end
            { value: val, error: nil }
          end
        rescue ::Timeout::Error
          { value: nil, error: "Expirada (Timeout)" }
        rescue StandardError => e
          { value: nil, error: e.message }
        end
      end
    end

    for i in 0...operations.size
      results[operations[i]] = threads[i].value
    end

    results
  end
end
