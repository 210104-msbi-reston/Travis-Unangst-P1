create table product
(
	pId int primary key,
	pName varchar(20),
	pCategory varchar(20),
	pPrice int,
	pQty int
)

declare @message varchar(250)
exec proc_Products 'DeleteById',101,@message



declare @message varchar(250)
exec proc_Products 'Add',101,@message


declare @message varchar(250)
exec proc_Products 'UpdateProductPrice',101,@message





create procedure proc_Products
(
	@action varchar(20),
	@pId int,
	@pName varchar(20),
	@pCategory varchar(20),
	@pPrice int,
	@pQty int,
	@result  varchar(250) output
)
as
begin
		if(@action = 'Add')
		begin
			insert into product values(@pId,@pName,@pCategory,@pPrice,@pQty)
			set @result = 'Product Added Successfully'
		end

		if(@action = 'DeleteById')
		begin
			delete from product where pId = @pId
			set @result = 'Product Added Successfully'

			
		end

			if(@action = 'UpdatePrice')
		begin
			update product set pPrice = @pPrice
			set @result = 'Product Price updated Successfully'
		end



end

