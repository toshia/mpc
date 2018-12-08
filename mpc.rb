# -*- coding: utf-8 -*-

require_relative 'model/world'

Plugin.create(:mpc) do
  world_setting(:mpc, 'MPC') do
    self[:host] = 'localhost'
    self[:port] = 6600
    label 'MPDサーバの情報を入力してください'
    input 'host', :host
    adjustment 'port', :port, 0, 65535
    mpd = Plugin::Mpc::World.new(await_input.to_h)
    info = mpd.server_info
    if info
      label 'このサーバを登録しますか？'
      label info
      mpd
    else
      Deferred.next{ Deferred.fail('サーバに接続できませんでした') }
    end
  end
end