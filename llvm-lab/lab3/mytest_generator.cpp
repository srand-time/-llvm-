#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>

#include <iostream>
#include <memory>

#ifdef DEBUG  // 用于调试信息,大家可以在编译过程中通过" -DDEBUG"来开启这一选项
#define DEBUG_OUTPUT std::cout << __LINE__ << std::endl;  // 输出行号的简单示例
#else
#define DEBUG_OUTPUT
#endif

using namespace llvm;  // 指明命名空间为llvm
#define CONST(num) \
  ConstantInt::get(context, APInt(32, num))  //得到常数值的表示,方便后面多次用到

int main() {
  LLVMContext context;
  Type *TYPE32 = Type::getInt32Ty(context);
  IRBuilder<> builder(context);
  auto module = new Module("assign", context);  // module name是什么无关紧要
// just use ctrl+c and  ctrl+v for above code


  auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main", module);	//declare main
 auto bb = BasicBlock::Create(context, "entry", mainFun);//entry
  builder.SetInsertPoint(bb);                     // 一个BB的开始
  auto aAlloca = builder.CreateAlloca(TYPE32);	  //int a
  //auto retAlloca = builder.CreateAlloca(TYPE32);  // 返回值的空间分配
  builder.CreateStore(CONST(1), aAlloca);	  //a=1
  auto aLoad = builder.CreateLoad(aAlloca); 	  //load a





  builder.CreateRet(aLoad);			  //return a

//ctrl+c and ctrl+v
  module->print(outs(), nullptr);
  delete module;
  return 0;
}
