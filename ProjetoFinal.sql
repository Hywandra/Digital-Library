

-- PROJETO FINAL

-- Criação Base Dados
create database DigitalLibrary
go

use DigitalLibrary

-- Criação de schema
create schema Gestao authorization [dbo]

-- Criação de tabelas
-- 1)
drop table if exists Gestao.Autor
go
create table Gestao.Autor(
ID_Autor int identity (1,1) not null constraint [PK_Autor_ID] primary key,
NomedoAutor varchar(100) not null,
Pais_Origem varchar(50) not null
)

-- 2)
drop table if exists Gestao.Genero
go
create table Gestao.Genero(
ID_Genero int identity (1,1) not null constraint [PK_Genero_ID] primary key,
NomedoGenero varchar(50) not null
)

-- 3)
drop table if exists Gestao.Livro
go
create table Gestao.Livro(
ID_Livro int identity (1,1) not null constraint [PK_Livro_ID] primary key,
Titulo varchar(200),
ID_Autor int not null,
constraint [FK_LivroAutor_ID] Foreign Key (ID_Autor) references Gestao.Autor(ID_Autor),
ID_Genero int not null,
constraint [FK_LivroGenero_ID] Foreign Key (ID_Genero) references Gestao.Genero(ID_Genero),
Disponivel bit not null
)

-- 4)
drop table if exists Gestao.Leitor
go
create table Gestao.Leitor(
ID_Leitor int identity (1,1) not null constraint [PK_Leitor_ID] primary key,
NomedoLeitor varchar(100) not null,
Email varchar(100) not null,
Telefone varchar(15) not null,
)

-- 5)
drop table if exists Gestao.Emprestimo
go
create table Gestao.Emprestimo(
ID_Emprestimo int identity (1,1) not null constraint [PK_Emprestimo_ID] primary key,
ID_Leitor int not null,
constraint [FK_EmprestimoLeitor_ID] Foreign Key (ID_Leitor) references Gestao.Leitor(ID_Leitor),
ID_Livro int not null,
constraint [FK_EmprestimoLivro_ID] Foreign Key (ID_Livro) references Gestao.Livro(ID_Livro),
Data_Emprestimo date not null,
Data_Devolucao date not null,
Devolvido bit not null
)

-- 6)
drop table if exists Gestao.HistoricoEmprestimo
go
create table Gestao.HistoricoEmprestimo(
ID_Historico int identity (1,1) not null constraint [PK_Historico_ID] primary key,
ID_Emprestimo int not null,
constraint [FK_HistoricoEmprestimo_ID] Foreign Key (ID_Emprestimo) references Gestao.Emprestimo(ID_Emprestimo),
Data_Devolucao_Real date
)

-- DADOS
-- 1)
insert into gestao.Autor (NomedoAutor, Pais_Origem)
values ('José Saramago', 'Portugal'),
		('J.K. Rowling', 'Reino Unido'),
		('George Orwell', 'Reino Unido'),
		('Stephen King', 'EUA'),
		('Isabel Allende', 'Chile');

select * from gestao.Autor

-- 2)
insert into gestao.Genero (NomedoGenero)
values ('Romance'),
		('Ficção Científica'),
		('Fantasia'),
		('Terror'),		
		('Drama');

select * from gestao.Autor

-- 3)
insert into gestao.Livro (Titulo, ID_Autor, ID_Genero, Disponivel)
values ('Ensaio sobre a Cegueira', '1', '1', '1'),
		('1984', '3', '2', '1'),
		('Harry Potter e a Pedra Filosofal', '2', '3', '1'),
		('O Iluminado', '4', '4', '1'),
		('A Casa dos Espíritos', '5', '1', '1');

select * from gestao.Livro

-- 4)
insert into gestao.Leitor (NomedoLeitor, Email, Telefone)
values ('Ana Silva', 'ana@gmail.com', '912345678'),
		('Pedro Santos', 'pedro@gmail.com', '915678234'),
		('Maria Oliveira', 'maria.oliveira@gmail.com', '918345678'),
		('João Almeida', 'joao.almeida@gmail.com', '917345123');

select * from gestao.Leitor

-- 5)
insert into gestao.Emprestimo (ID_Leitor, ID_Livro, Data_Emprestimo, Data_Devolucao, Devolvido)
values ('1', '1', '2024-12-01', '2024-12-15', '0'),
		('2', '2', '2024-12-02', '2024-12-16', '0'),
		('1', '3', '2024-12-01', '2024-12-15', '0');

select * from gestao.Emprestimo

-- 6)
insert into gestao.HistoricoEmprestimo (ID_Emprestimo, Data_Devolucao_Real)
values ('1', null),
		('2', null);

select * from gestao.HistoricoEmprestimo

-- Criação de Objetos
-- Views
-- 1)
Drop view if exists Gestao.vwLivrosEmprestados
go
CREATE VIEW Gestao.vwLivrosEmprestados
AS
select lv.titulo,
		lt.Nomedoleitor,
		a.NomedoAutor,
		g.NomedoGenero
from gestao.leitor as LT
inner join gestao.emprestimo as E
	on e.ID_leitor=LT.ID_leitor
inner join gestao.livro as LV
	on e.ID_livro=LV.ID_livro
inner join gestao.autor as A
	on lv.ID_autor=a.ID_autor
inner join gestao.genero as G
	on lv.ID_genero=g.ID_genero

select * from Gestao.vwLivrosEmprestados

-- 2)
Drop view if exists Gestao.vwAtrasoLeitor
go
CREATE VIEW Gestao.vwAtrasoLeitor
AS
select lt.nomedoleitor,						
		lv.titulo,
		e.Data_Emprestimo,
		e.Devolvido,
		datediff (day, e.Data_Emprestimo, getdate()) as Dias_Emprestimo		
from gestao.leitor as LT
inner join gestao.emprestimo as E
	on e.ID_leitor=LT.ID_leitor
inner join gestao.livro as LV
	on e.ID_livro=LV.ID_livro
where e.devolvido=0 and 15>Dias_Emprestimo					-- AQUI!!!

select * from Gestao.vwAtrasoLeitor

select * from gestao.Emprestimo

-- Stored Procedures
-- 1)
drop procedure if exists dbo.AddEmprestimo
go
create procedure dbo.AddEmprestimo(
@idLeitor int,				
@idLivro int,							
@dataEmprestimo date,		
@dataDevolucao date,
@devolvido bit
)
AS
insert Gestao.Emprestimo(ID_Leitor, ID_Livro, Data_Emprestimo, Data_Devolucao, Devolvido)
values (@idLeitor, @idLivro, @dataEmprestimo, @dataDevolucao, @devolvido)
			
exec dbo.AddEmprestimo 2, 2, '2024-12-12', '2024-12-28', 0

select * from gestao.Emprestimo

-- 2)
drop procedure if exists dbo.ListarGenero
go
create procedure dbo.ListarGenero(
@idgenero varchar(100)
)
AS
select  g.NomedoGenero,
		l.Titulo
from gestao.Genero as g
inner join Gestao.Livro as l
on g.ID_Genero=l.ID_Genero
where g.ID_Genero=@idgenero
			
exec dbo.ListarGenero 1					-- ENTRA EM LOOP!!!

select * from gestao.Livro

-- Triggers
-- 1)
-- Criação da tabela de verificação
drop table if exists gestao.DisponLivro
go
create table gestao.DisponLivro(
ID int identity (1,1) not null constraint [PK_DisponLivro_ID] primary key,
ID_Emprestimo int not null,
ID_Livro int not null,
Disponivel bit,
Operacao VARCHAR(50) --: Tipo de operação registada (INSERT, UPDATE???)
);

-- criação de trigger
drop trigger if exists gestao.tgg_DisponLivro
go
create trigger gestao.tgg_DisponLivro
on gestao.emprestimo
after insert, update
as
begin
set nocount on;
update Emprestimo
	SET  Devolvido = 0;
	insert into gestao.DisponLivro			
		(ID_Emprestimo, ID_Livro, Disponivel, Operacao)			
	select i.ID_Emprestimo, i.ID_Livro,
		i.Devolvido, 'Insert'	
	FROM Emprestimo as E   					
	INNER JOIN inserted as I					
		on e.ID_Emprestimo=i.ID_Emprestimo
	-- where disponivel = Devolvido
END;
go
													
-- Testar							
--Inserir dados									
insert into gestao.Emprestimo					
   (ID_Leitor, ID_Livro, Data_Emprestimo, Data_Devolucao, Devolvido)	
values (4, 4, '2024-12-10', '2024-12-25', 0);								
												
-- Verificação									
select	ID_Emprestimo, ID_Livro, Disponivel, Operacao				
from gestao.DisponLivro

select * from gestao.emprestimo

-- 2)
-- Criação da tabela de verificação
drop table if exists gestao.HistorReques
go
create table gestao.HistorReques(
ID int identity (1,1) not null constraint [PK_HistorReques_ID] primary key,
ID_Emprestimo int not null,
DataReal datetime not null default getdate(),
Operacao VARCHAR(50)
);

-- criação de trigger
drop trigger if exists gestao.tgg_DisponLivro
go
create trigger gestao.tgg_DisponLivro
on gestao.historicoemprestimo
after insert, update
as
begin
set nocount on;
   update Emprestimo
   SET  Devolvido = 1;
   insert into gestao.HistorReques			
   (ID_Emprestimo, DataReal, Operacao)			
   select i.ID_Emprestimo, i.Data_Devolucao_Real, 'Insert'	
   FROM historicoemprestimo as H   					
   INNER JOIN inserted as I					
	on h.ID_Emprestimo=i.ID_Emprestimo   		
END;
go
													
-- Testar							
--Inserir dados									
insert into gestao.Emprestimo					
	(ID_Leitor, ID_Livro, Data_Emprestimo, Data_Devolucao, Devolvido)	-- COMO INSERIR???
values --(5, 1);								
	(4, 4, '2024-12-10', '2024-12-19', 1)										
-- Verificação									
select ID_Emprestimo, DataReal							
from gestao.HistorReques

-- não consegui terminar o último trigger

