/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package Interfaces;

import entidades.Pedidos;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.List;

/**
 *
 * @author Acer
 */

public interface IGestionPedidosRemoto extends Remote {
    // Operaciones transaccionales
    boolean registrarPedidoWeb(Pedidos pedido) throws RemoteException;
    boolean actualizarEstadoPedido(int idPedido, String nuevoEstado, String nuevaNota) throws RemoteException;
    boolean cancelarPedido(int idPedido) throws RemoteException;
    boolean registrarPago(entidades.Pagos pago) throws RemoteException;
    
    // Consultas para las vistas
    Pedidos buscarPedidoPorId(int idPedido) throws RemoteException;
    List<Pedidos> listarPedidosPorCliente(int idCliente) throws RemoteException;
    List<Pedidos> listarPedidosPorTrackingTab(String tipoTab) throws RemoteException;
    List<Pedidos> listarTodosPedidos() throws RemoteException;
    
    // Métodos para los indicadores del Dashboard Administrativo
    long contarPedidosHoy() throws RemoteException;
    double calcularIngresosMes() throws RemoteException;
    long contarEnProceso() throws RemoteException;
    long contarTerminados() throws RemoteException;
    
    // Métodos para el Dashboard del Cliente
    long contarActivosCliente(int idCliente) throws RemoteException;
    long contarCompletadosCliente(int idCliente) throws RemoteException;
    java.math.BigDecimal sumarTotalGastadoCliente(int idCliente) throws RemoteException;
    List<Pedidos> listarRecientesCliente(int idCliente) throws RemoteException;
}