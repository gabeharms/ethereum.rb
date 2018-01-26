require 'open3'

namespace :ethereum do
  namespace :node do
    desc "Start private chain node"
    task :start, [:genesis_file_path, :data_dir_path, :network_id] do |t, args|
      cmd = "geth init #{args[:genesis_file_path]} --datadir #{args[:data_dir_path]}"
      puts cmd
      system cmd
      
      cmd = "geth --datadir #{args[:data_dir_path]} --networkid #{args[:network_id]}"
      puts cmd
      system cmd
    end

    desc "Attach console to existing private chain"
    task :attach, [:ipc_file_path] do |t, args|
      cmd = "geth attach #{args[:ipc_file_path]}"
      puts cmd
      system cmd
    end
    
    
    desc "Run production node"
    task :run do
      _, out, _ = Open3.capture3("parity account list")
      account = out.split(/[\[,\]]/)[1]
      system "parity --password ~/.parity/pass --unlock #{account}  --author #{account} --no-jsonrpc"
    end

    desc "Mine ethereum testing environment for ethereum node"
    task :mine do
        cmd = "ethminer"
        puts cmd
        system cmd
    end

    desc "Check if node is syncing"
    task :waitforsync do
      formatter = Ethereum::Formatter.new
      begin
        loop do
           result = Ethereum::Singleton.instance.eth_syncing["result"]
           unless result
             puts "Synced"
             break
           else
             current = formatter.to_int(result["currentBlock"])
             highest = formatter.to_int(result["highestBlock"])
             puts "Syncing block: #{current}/#{highest}"
           end
           sleep 5
        end
      rescue
        puts "Ethereum node not running?"
      end
    end

  end
end
