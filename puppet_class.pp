class puppet_class {
  
  Package{ ensure => 'installed' }
  $enhancers = [ 'Vim', 'Curl', 'Git' ]
  package{ $enhancers: }
  
  user{ 'monitor':
    home  => '/home/monitor',
    shell => '/bin/bash',
  }
  
  file{ '/home/monitor/scripts/memory_check':
    mode    =>  0755,
    require =>  Exec["retrieve_file"],
  }
  
  exec{ 'retrieve_file':
    command => "/usr/bin/wget -q https://raw.githubusercontent.com/Angelo0720/Codes/master/memory_check.sh",
    creates => "/home/monitor/scripts/memory_check",
  }
  
  file{'home/monitor/src/my_memory_check':
    ensure  => 'link',
    target  => '/home/monitor/scripts/memory_check',  
  }
  
  cron{'check':
    command => "home/monitor/src/my_memory_check",
    hour    => '*',
    minute  => '*/10',
    require => File['home/monitor/src/my_memory_check'],
  }
}
