meta "file" do
  accepts_value_for :source
  accepts_value_for :target
  accepts_value_for :owner, "root"
  accepts_value_for :group, "root"
  accepts_value_for :permissions, "644"

  template {
    def source_path
      dependency.load_path.parent / source
    end

    met? { target.p.file? && target.p.owner == owner && target.p.group == group && File.stat(target).mode.to_s(8)[3..5] == permissions && source_path.read == target.p.read } 
    meet {
      target.p.parent.create_dir
      target.p.open("w+") do |f|
        f << source_path.read
      end
      shell! "chown #{owner}:#{group} #{target}"
      shell! "chmod #{permissions} #{target}"
    }
  }
end

