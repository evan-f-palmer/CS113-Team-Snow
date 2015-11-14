local Class  = require('hump.class')

local Heap = Class{}

function Heap:init(priority)
  self.priority = priority
  self.used = 0
  self.data = {}
end

local function leftChild(i)
  return 2 * i
end

local function rightChild(i)
  return 2 * i + 1
end

local function parent(i)
  return math.floor(i / 2)
end

local function isRoot(i)
  return i == 1
end

function Heap:isInHeap(i)
  return i <= self.used and i >= 1
end

function Heap:swap(i, j)
  local tmp = self.data[i]
  self.data[i] = self.data[j]
  self.data[j] = tmp
end

function Heap:percolateDown(i)
  if self:isInHeap(leftChild(i)) and self:isInHeap(rightChild(i)) then
    local max
    if self.priority(self.data[leftChild(i)], self.data[rightChild(i)]) then
      max = leftChild(i)
    else
      max = rightChild(i)
    end
    self:swap(i, max)
    self:percolateDown(max)
  elseif self:isInHeap(leftChild(i)) and self.priority(self.data[leftChild(i)], self.data[i]) then
    self:swap(i, leftChild(i))
    self:percolateDown(leftChild(i))
  elseif self:isInHeap(rightChild(i)) and self.priority(self.data[rightChild(i)], self.data[i]) then
    self:swap(i, rightChild(i))
    self:percolateDown(rightChild(i))
  end
end

function Heap:percolateUp(i)
  if self:isInHeap(parent(i)) and self.priority(self.data[i], self.data[parent(i)]) then
    self:swap(i, parent(i))
    self:percolateUp(parent(i))
  end
end

function Heap:peek()
  return self.data[1]
end

function Heap:add(element)
  self.data[self.used + 1] = element
  self:percolateUp(self.used + 1)
  self.used = self.used + 1
end

function Heap:remove()
  local tmp = self.data[1]
  self.data[1] = self.data[self.used - 1]
  self:percolateDown(1)
  table.remove(self.data, self.used - 1)
  self.used = self.used - 1
  return tmp
end

function Heap:clear()
  for k, _ in pairs(self.data) do
    self.data[k] = nil
  end
  self.data = nil
  self:init(self.priority)
end

function Heap:size()
  return self.used
end

function Heap:isEmpty()
  return self.used == 0
end

return Heap