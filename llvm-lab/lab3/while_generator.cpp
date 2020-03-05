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
  auto module = new Module("while", context);  // module name是什么无关紧要
// just use ctrl+c and  ctrl+v for above code
  auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main", module);	//declare main
 auto bb = BasicBlock::Create(context, "entry", mainFun);//entry
  builder.SetInsertPoint(bb);                     // 一个BB的开始

 auto loopBB = BasicBlock::Create(context, "", mainFun);    // loop分支
  auto falseBB = BasicBlock::Create(context, "falseBB", mainFun);    // after分支
  auto trueBB = BasicBlock::Create(context, "trueBB", mainFun);
  auto aAlloca = builder.CreateAlloca(TYPE32);	  //int a
  auto iAlloca = builder.CreateAlloca(TYPE32);	  //int i
  builder.CreateStore(CONST(10), aAlloca);	  //a=10
   builder.CreateStore(CONST(0), iAlloca);	  //i=0
  
//while start
  builder.SetInsertPoint(loopBB);
  builder.CreateBr(loopBB);
  auto iLoad = builder.CreateLoad(iAlloca); 	  //load i
  auto icmp = builder.CreateICmpSLT(iLoad,CONST(10)); //if(i<10)
  auto br = builder.CreateCondBr(icmp,trueBB,falseBB);  // 条件BR

  builder.SetInsertPoint(trueBB);
  auto iLoad2 = builder.CreateLoad(iAlloca);
  auto add1 = builder.CreateNSWAdd(CONST(1), iLoad2); //i=i+1
  builder.CreateStore(add1, iAlloca);
  auto aLoad=builder.CreateLoad(aAlloca); 
  auto iLoad3 = builder.CreateLoad(iAlloca);
  auto add2 = builder.CreateNSWAdd(aLoad, iLoad3); //a=a+i
  builder.CreateStore(add2, aAlloca);
  builder.CreateBr(loopBB);
//end while
  
  builder.SetInsertPoint(falseBB); 
  aLoad=builder.CreateLoad(aAlloca);
  builder.CreateRet(aLoad);

  
//ctrl+c and ctrl+v
  module->print(outs(), nullptr);
  delete module;
  return 0;
}
