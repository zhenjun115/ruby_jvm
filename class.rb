# 读取文件
require( './helper.rb' )
working_dir = "./"
java_class_filename = "helloworld.class"
#java_class_filename = "LoginAction.class"

file = File.new( java_class_filename )
read_magic( file ) #读取魔数
read_minor_version( file )
read_major_version( file )
read_constant_pool_count( file )
read_constant_pool( file )
read_access_flags( file )
result()
file.close()
