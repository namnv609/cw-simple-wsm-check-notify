require "chatwork"
require "yaml"

app_settings = YAML.load_file "settings.yml"
chatwork_settings = app_settings["chatwork"]
ChatWork.api_key = chatwork_settings["api_key"]

def get_room_list
  ChatWork::Room.get
end

def get_room_members room_id
  ChatWork::Member.get room_id: room_id
end

rooms = get_room_list.delete_if{|r| chatwork_settings["ignore_rooms"].include?(r["room_id"])}

rooms.each do |room|
  member_ids = get_room_members(room["room_id"]).map{|member| member["account_id"]}
    .delete_if{|member_id| chatwork_settings["ignore_user_ids"].include?(member_id)}

  message_body = "[To:#{member_ids.join("] [To:")}]\n\n"
  message_body << "Mọi người vui lòng check timeshet của mình tại https://wsm.framgia.vn nhé"
  status = ChatWork::Message.create room_id: room["room_id"], body: message_body

  puts status
end

puts "Done!!!"
