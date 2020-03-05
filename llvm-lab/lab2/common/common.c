//#include "common.h"
#include <dirent.h>

int getAllTestcase(char filename[][256])
{
	/// \todo student should fill this function
	DIR *dir;
	struct dirent *entry;
	int m=0;
	if (!(dir=opendir("./testcase"))){
		printf("[ERR] No input file\n");
		exit(1);
	}
	while(entry=readdir(dir)){
		char temp[8];
		int len=strlen(entry->d_name);
		int i;
		if (len<8){
			continue;
		}
		for (i=0;i<7;i++)
		{
			temp[i]=entry->d_name[len-7+i];
		}
		if (!strcmp(temp,".cminus")){
			strcpy(filename[m],entry->d_name);
			m++;
		}	
	}
	closedir(dir);
	return m;
}

