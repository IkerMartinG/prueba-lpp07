# TDD/spec/matrix_spec.rb
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require_relative "../lib/matrix"

RSpec.describe MatrixOperations do
  before(:all) do
    @m1 = [[1, 2], [3, 4]]
    @m2 = [[5, 6], [7, 8]]
    @scalar = 2
  end

  it "suma dos matrices de NxN correctamente" do
    expect(MatrixOperations.add(@m1, @m2)).to eq([[6, 8], [10, 12]])
  end

  it "calcula el producto escalar de una matriz" do
    expect(MatrixOperations.scalar_product(@m1, @scalar)).to eq([[2, 4], [6, 8]])
  end

  it "transpone una matriz de NxN" do
    expect(MatrixOperations.transpose(@m1)).to eq([[1, 3], [2, 4]])
  end

  it "devuelve un resultado por cada operación pedida y ninguna más" do
    ops = [:add, :scalar_product]
    result = MatrixOperations.configurable_concurrent(@m1, @m2, @scalar, operations: ops, max_threads: 2, timeout: 5)
    expect(result.keys).to match_array(ops)
  end

  it "si una operación falla, las otras terminan y el error queda registrado en la salida" do
    # Forzamos un fallo pasando operandos incompatibles en la suma
    ops = [:add, :scalar_product]
    result = MatrixOperations.configurable_concurrent([[1]], @m2, @scalar, operations: ops, max_threads: 2, timeout: 5)
    expect(result[:add][:error]).not_to be_nil
    expect(result[:scalar_product][:value]).not_to be_nil
  end

  it "una operación que supera el tiempo máximo (timeout) se marca como expirada" do
    ops = [:slow_op]
    result = MatrixOperations.configurable_concurrent(@m1, @m2, @scalar, operations: ops, max_threads: 1, timeout: 0.01)
    expect(result[:slow_op][:error]).to include("Expirada")
  end
end
