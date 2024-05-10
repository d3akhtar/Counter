class('ListNode').extends()
function ListNode:init(next,prev,val)
    self.next = next
    self.prev = prev
    self.val = val
end