require 'open-uri'

class Convert
  def process
    #less_files.each do |name, file|
    #  file = open_git_file(file)
    #  file = convert(file)
    #  save_file(name, file)
    #end

    #self.process_mixins

    self.create_sass_files
  end

  def process_mixins
    file = 'https://raw.github.com/twitter/bootstrap/master/lib/mixins.less'
    file = open_git_file(file)
    file = replace_mixins(file)
    save_file('_mixins', file)
  end

  
  def create_sass_files
    scss_files = 'stylesheets'
    


    Dir.glob(scss_files+'/*').each do |dir|
      file_or_dir = File.open dir

      if File.file? file_or_dir
        convert_scss(file_or_dir)
      else
        Dir.open(file_or_dir).each do |filename|
          file = File.open("#{file_or_dir.path}/#{filename}")
          next unless File.fnmatch? '**.scss', file
          convert_scss(file, 'compass_twitter_bootstrap/')
        end
      end

      #puts File.file? file

    end


    #Dir.open(scss_files).each do |filename|
    #  file = File.open("#{scss_files}/#{filename}")
    #  next unless File.fnmatch? '**.scss', file

    #  if File.directory? file
    #    puts "#{filename} - Dir? #{File.directory?(file)}"
    #  else
    #    system("sass-convert #{file.path} #{sass_files}/#{File.basename(file, 'scss')}sass")
    #    puts "#{filename} - File? #{File.file?(file)}"
    #  end
      


      # otherwise, process file  
    #end   
  end

private

  def less_files
    {
      '_reset'       => 'https://raw.github.com/twitter/bootstrap/master/lib/reset.less',
      '_variables'   => 'https://raw.github.com/twitter/bootstrap/master/lib/variables.less',
      '_scaffolding' => 'https://raw.github.com/twitter/bootstrap/master/lib/scaffolding.less',
      '_type'        => 'https://raw.github.com/twitter/bootstrap/master/lib/type.less',
      '_forms'       => 'https://raw.github.com/twitter/bootstrap/master/lib/forms.less',
      '_tables'      => 'https://raw.github.com/twitter/bootstrap/master/lib/tables.less',
      '_patterns'    => 'https://raw.github.com/twitter/bootstrap/master/lib/patterns.less'
    }
  end

  def convert(file)
    file = replace_vars(file)
    file = replace_fonts(file)
    file = replace_grads(file)
    file = replace_mixins(file)
    file = replace_includes(file)
    file = replace_spin(file)

    file
  end

  def open_git_file(file)
    open(file).read
  end

  def save_file(name, content)
    f = File.open("stylesheets/compass_twitter_bootstrap/#{name}.scss", "w+")
    f.write(content)
    f.close
    puts "Converted#{name}\n"
  end

  def replace_vars(less)
    less.gsub(/@/, '$')
  end

  def replace_fonts(less)
    less.gsub(/#font \> \.([\w-]+)/, '@include \1')
  end

  def replace_grads(less)
    less.gsub(/#gradient \> \.([\w-]+)/, '@include gradient-\1')
  end

  def replace_mixins(less)
    less.gsub(/^\.([\w-]*)(\(.*\))([\s\{]+)$/, '@mixin \1\2\3')
  end

  def replace_includes(less)
    less.gsub(/\.([\w-]*)(\(.*\));?/, '@include \1\2;')
  end

  def replace_spin(less)
    less.gsub(/spin/, 'adjust-hue')
  end

  def convert_scss(file, folder='')
    sass_files = 'stylesheets_sass'
    system("sass-convert #{file.path} #{sass_files}/#{folder}#{File.basename(file, 'scss')}sass")
  end

end

Convert.new.process
