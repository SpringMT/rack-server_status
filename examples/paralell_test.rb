require 'parallel'
require 'net/http'
$proc_num = 5
$execute_num = 10

Parallel.map([1,2,3,4,5,6], :in_processes => $proc_num) do |letter|
  $execute_num.times do
    http = Net::HTTP.new('localhost', 3000)
    req = Net::HTTP::Get.new('/foo')
    http.request(req)
  end
end

