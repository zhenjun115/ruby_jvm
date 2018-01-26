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
read_this_class( file )
read_super_class( file )
read_interfaces_count( file )
read_interfaces( file )
read_fields_count( file )
read_fields( file )
read_methods_count( file )
read_methods( file )
read_attributes_count( file )
read_attributes( file )
result()
file.close()
