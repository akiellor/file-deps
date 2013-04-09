meta "owner_file" do
  accepts_value_for :source
  accepts_value_for :target
  accepts_value_for :owner, "root"
  accepts_value_for :group, "root"
  accepts_value_for :permissions, "744"

  template {
    def source_path
      dependency.load_path.parent / source
    end

    def target_path
      home_path / target
    end

    def home_path
      Etc.getpwnam(owner).dir.p
    end

    def paths
      target_path.expand_path.to_enum(:descend).to_a - home_path.expand_path.to_enum(:descend).to_a
    end

    met? { paths.all? {|p| p.exist? && p.owner == owner && p.group == group && File.stat(p).mode.to_s(8)[-3..-1] == permissions } && source_path.read == target_path.read } 
    meet {
      target_path.parent.create_dir
      target_path.open("w+") do |f|
        f << source_path.read
      end
      paths.each do |p|
        shell! "chown #{owner}:#{group} #{p}"
        shell! "chmod #{permissions} #{p}"
      end
    }
  }
end

