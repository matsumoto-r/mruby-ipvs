MRuby::Gem::Specification.new('mruby-ipvs') do |spec|
  spec.license = 'GNU General Public License'
  spec.author  = 'YOSHIKAWA Ryota'

  require 'open3'

  def run_command env, command
    STDOUT.sync = true
    puts "build: [exec] #{command}"
    Open3.popen2e(env, command) do |stdin, stdout, thread|
      print stdout.read
      fail "#{command} failed" if thread.value != 0
    end
  end

  Dir.chdir spec.dir do
    e = {
      'CC' => "#{spec.build.cc.command} #{spec.build.cc.flags.join(' ')}",
      'CXX' => "#{spec.build.cxx.command} #{spec.build.cxx.flags.join(' ')}",
      'LD' => "#{spec.build.linker.command} #{spec.build.linker.flags.join(' ')}",
      'AR' => spec.build.archiver.command,
    }

    run_command e, "git submodule update --init"
  end

  spec.cc.include_paths << "#{spec.dir}/ipvsadm/libipvs"
  spec.linker.libraries << ['nl']
  spec.objs << (Dir.glob("#{spec.dir}/src/*.c") +
                Dir.glob("#{spec.dir}/ipvsadm/libipvs/*.c")).map do |f|
    f.relative_path_from(spec.dir).pathmap("#{build_dir}/%X.o")
  end
end
