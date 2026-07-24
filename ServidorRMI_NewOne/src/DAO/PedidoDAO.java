/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import Interfaces.IGestionPedidosRemoto;
import entidades.Citas;
import entidades.DetallePedido;
import entidades.Pedidos;
import conexion.connectionDrive;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.Query;

public class PedidoDAO extends UnicastRemoteObject implements IGestionPedidosRemoto {

    public PedidoDAO() throws RemoteException {
        super();
    }

    @Override
    public boolean registrarPedidoWeb(Pedidos pedido) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(pedido);
            
            if (pedido.getDetallePedidoList() != null) {
                for (DetallePedido dp : pedido.getDetallePedidoList()) {
                    if (dp.getIdProducto() != null) {
                        entidades.Productos prod = em.find(entidades.Productos.class, dp.getIdProducto().getIdProducto());
                        if (prod != null && prod.getStock() != null) {
                            int nuevoStock = prod.getStock() - dp.getCantidad();
                            if (nuevoStock < 0) nuevoStock = 0;
                            prod.setStock(nuevoStock);
                            em.merge(prod);
                        }
                    }
                }
            }
            
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean actualizarEstadoPedido(int idPedido, String nuevoEstado, String nuevaNota) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Pedidos p = em.find(Pedidos.class, idPedido);
            if (p != null) {
                p.setEstado(nuevoEstado);
                if (nuevaNota != null && !nuevaNota.trim().isEmpty()) {
                    String notaExistente = p.getNotasAdicionales() != null ? p.getNotasAdicionales() : "";
                    p.setNotasAdicionales(nuevaNota + "\n" + notaExistente);
                }
                p.setFechaActualizacion(new java.util.Date());
                em.merge(p);
                tx.commit();
                return true;
            }
            return false;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean cancelarPedido(int idPedido) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Pedidos p = em.find(Pedidos.class, idPedido);
            if (p != null) {
                // Borramos las citas asociadas si existen
                List<Citas> citas = em.createQuery("SELECT c FROM Citas c WHERE c.idCliente = :cli AND c.estado = 'Confirmada'", Citas.class)
                                      .setParameter("cli", p.getIdCliente()).getResultList();
                for(Citas c : citas) {
                    em.remove(c);
                }
                em.remove(p);
                tx.commit();
                return true;
            }
            return false;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public Pedidos buscarPedidoPorId(int idPedido) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            Pedidos p = em.find(Pedidos.class, idPedido);
            if (p != null) {
                em.detach(p);
                if (p.getDetallePedidoList() != null) {
                    List<DetallePedido> detalles = new ArrayList<>(p.getDetallePedidoList());
                    p.setDetallePedidoList(detalles);
                    for (DetallePedido dp : detalles) {
                        em.detach(dp);
                        dp.setIdPedido(null);
                        if (dp.getIdProducto() != null) {
                            em.detach(dp.getIdProducto());
                            dp.getIdProducto().setDetallePedidoList(null);
                        }
                        if (dp.getIdServicio() != null) {
                            em.detach(dp.getIdServicio());
                            dp.getIdServicio().setDetallePedidoList(null);
                        }
                    }
                }
                if (p.getIdCliente() != null) {
                    em.detach(p.getIdCliente());
                    p.getIdCliente().setPedidosList(null);
                    p.getIdCliente().setCitasList(null);
                }
                if (p.getIdEmpleado() != null) {
                    em.detach(p.getIdEmpleado());
                    p.getIdEmpleado().setPedidosList(null);
                }
                p.setPagosList(null);
            }
            return p;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public List<Pedidos> listarPedidosPorCliente(int idCliente) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            em.getEntityManagerFactory().getCache().evictAll();
            String sql = "SELECT p FROM Pedidos p WHERE p.idCliente.idCliente = :idCliente ORDER BY p.idPedido DESC";
            List<Pedidos> lista = em.createQuery(sql, Pedidos.class).setParameter("idCliente", idCliente).getResultList();
            for (Pedidos p : lista) {
                em.detach(p);
                if (p.getDetallePedidoList() != null) {
                    List<DetallePedido> detalles = new ArrayList<>(p.getDetallePedidoList());
                    p.setDetallePedidoList(detalles);
                    for (DetallePedido dp : detalles) {
                        em.detach(dp);
                        dp.setIdPedido(null);
                        if (dp.getIdProducto() != null) {
                            em.detach(dp.getIdProducto());
                            dp.getIdProducto().setDetallePedidoList(null);
                        }
                        if (dp.getIdServicio() != null) {
                            em.detach(dp.getIdServicio());
                            dp.getIdServicio().setDetallePedidoList(null);
                        }
                    }
                }
                if (p.getIdCliente() != null) {
                    em.detach(p.getIdCliente());
                    p.getIdCliente().setPedidosList(null);
                    p.getIdCliente().setCitasList(null);
                }
                if (p.getIdEmpleado() != null) {
                    em.detach(p.getIdEmpleado());
                    p.getIdEmpleado().setPedidosList(null);
                }
                p.setPagosList(null);
            }
            return lista;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public List<Pedidos> listarPedidosPorTrackingTab(String tipoTab) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            em.getEntityManagerFactory().getCache().evictAll(); // Limpiar caché para ver datos frescos
            List<Pedidos> resultado = new ArrayList<>();
            
            if ("servicios".equals(tipoTab)) {
                String sql = "SELECT DISTINCT p FROM Pedidos p JOIN p.detallePedidoList dp WHERE dp.idServicio IS NOT NULL ORDER BY p.idPedido DESC";
                resultado = em.createQuery(sql, Pedidos.class).getResultList();
            } else {
                String sql = "SELECT DISTINCT p FROM Pedidos p JOIN p.detallePedidoList dp WHERE dp.idProducto IS NOT NULL ORDER BY p.idPedido DESC";
                List<Pedidos> todosProductos = em.createQuery(sql, Pedidos.class).getResultList();
                
                for(Pedidos p : todosProductos) {
                    String notas = p.getNotasAdicionales() != null ? p.getNotasAdicionales() : "";
                    if ("delivery".equals(tipoTab) && (notas.contains("Delivery") || notas.contains("Envío"))) {
                        resultado.add(p);
                    } else if ("recojo".equals(tipoTab) && !(notas.contains("Delivery") || notas.contains("Envío"))) {
                        resultado.add(p);
                    }
                }
            }
            
            for (Pedidos p : resultado) {
                em.detach(p);
                if (p.getDetallePedidoList() != null) {
                    List<DetallePedido> detalles = new ArrayList<>(p.getDetallePedidoList());
                    p.setDetallePedidoList(detalles);
                    for (DetallePedido dp : detalles) {
                        em.detach(dp);
                        dp.setIdPedido(null);
                        if (dp.getIdProducto() != null) {
                            em.detach(dp.getIdProducto());
                            dp.getIdProducto().setDetallePedidoList(null);
                        }
                        if (dp.getIdServicio() != null) {
                            em.detach(dp.getIdServicio());
                            dp.getIdServicio().setDetallePedidoList(null);
                        }
                    }
                }
                if (p.getIdCliente() != null) {
                    em.detach(p.getIdCliente());
                    p.getIdCliente().setPedidosList(null);
                    p.getIdCliente().setCitasList(null);
                }
                if (p.getIdEmpleado() != null) {
                    em.detach(p.getIdEmpleado());
                    p.getIdEmpleado().setPedidosList(null);
                }
                p.setPagosList(null);
            }
            
            return resultado;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public long contarPedidosHoy() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            Query q = em.createNativeQuery("SELECT COUNT(*) FROM Pedidos WHERE CAST(fecha_recepcion AS DATE) = CAST(GETDATE() AS DATE)");
            return ((Number) q.getSingleResult()).longValue();
        } catch(Exception e) { return 0; }
        finally { if (em != null && em.isOpen()) em.close(); }
    }

    @Override
    public double calcularIngresosMes() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            Query q = em.createNativeQuery("SELECT ISNULL(SUM(monto_total), 0) FROM Pedidos WHERE MONTH(fecha_recepcion) = MONTH(GETDATE()) AND YEAR(fecha_recepcion) = YEAR(GETDATE())");
            Object res = q.getSingleResult();
            return res != null ? ((Number) res).doubleValue() : 0.0;
        } catch(Exception e) { return 0.0; }
        finally { if (em != null && em.isOpen()) em.close(); }
    }

    @Override
    public long contarEnProceso() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            return (long) em.createQuery("SELECT COUNT(p) FROM Pedidos p WHERE p.estado NOT IN ('Terminado', 'Entregado', 'Cancelado')").getSingleResult();
        } catch(Exception e) { return 0; }
        finally { if (em != null && em.isOpen()) em.close(); }
    }

    @Override
    public long contarTerminados() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            return (long) em.createQuery("SELECT COUNT(p) FROM Pedidos p WHERE p.estado = 'Terminado'").getSingleResult();
        } catch(Exception e) { return 0; }
        finally { if (em != null && em.isOpen()) em.close(); }
    }

    @Override
    public long contarActivosCliente(int idCliente) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            em.getEntityManagerFactory().getCache().evictAll();
            Query q = em.createQuery("SELECT COUNT(p) FROM Pedidos p WHERE p.idCliente.idCliente = :c AND p.estado NOT IN ('Entregado', 'Cancelado')");
            q.setParameter("c", idCliente);
            return (long) q.getSingleResult();
        } catch(Exception e) { return 0; }
        finally { if (em != null && em.isOpen()) em.close(); }
    }

    @Override
    public long contarCompletadosCliente(int idCliente) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            em.getEntityManagerFactory().getCache().evictAll();
            Query q = em.createQuery("SELECT COUNT(p) FROM Pedidos p WHERE p.idCliente.idCliente = :c AND p.estado = 'Entregado'");
            q.setParameter("c", idCliente);
            return (long) q.getSingleResult();
        } catch(Exception e) { return 0; }
        finally { if (em != null && em.isOpen()) em.close(); }
    }

    @Override
    public java.math.BigDecimal sumarTotalGastadoCliente(int idCliente) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            em.getEntityManagerFactory().getCache().evictAll();
            Query q = em.createQuery("SELECT SUM(p.montoTotal) FROM Pedidos p WHERE p.idCliente.idCliente = :c AND p.estado <> 'Cancelado'");
            q.setParameter("c", idCliente);
            java.math.BigDecimal total = (java.math.BigDecimal) q.getSingleResult();
            return total != null ? total : java.math.BigDecimal.ZERO;
        } catch(Exception e) { return java.math.BigDecimal.ZERO; }
        finally { if (em != null && em.isOpen()) em.close(); }
    }

    @Override
    public List<Pedidos> listarRecientesCliente(int idCliente) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            em.getEntityManagerFactory().getCache().evictAll();
            String sql = "SELECT * FROM Pedidos p " +
                         "WHERE p.id_cliente = ? " +
                         "AND (" +
                         "  (p.estado NOT IN ('Entregado', 'Cancelado')) " +
                         "  OR " +
                         "  (p.estado IN ('Entregado', 'Cancelado') AND DATEDIFF(SECOND, ISNULL(p.fecha_actualizacion, p.fecha_recepcion), GETDATE()) <= 120) " +
                         ") " +
                         "ORDER BY p.id_pedido DESC";
            
            Query qList = em.createNativeQuery(sql, Pedidos.class);
            qList.setParameter(1, idCliente);
            qList.setMaxResults(5);
            List<Pedidos> lista = qList.getResultList();
            for (Pedidos p : lista) {
                em.detach(p);
                if (p.getDetallePedidoList() != null) {
                    List<DetallePedido> detalles = new ArrayList<>(p.getDetallePedidoList());
                    p.setDetallePedidoList(detalles);
                    for (DetallePedido dp : detalles) {
                        em.detach(dp);
                        dp.setIdPedido(null);
                        if (dp.getIdProducto() != null) {
                            em.detach(dp.getIdProducto());
                            dp.getIdProducto().setDetallePedidoList(null);
                        }
                        if (dp.getIdServicio() != null) {
                            em.detach(dp.getIdServicio());
                            dp.getIdServicio().setDetallePedidoList(null);
                        }
                    }
                }
                if (p.getIdCliente() != null) {
                    em.detach(p.getIdCliente());
                    p.getIdCliente().setPedidosList(null);
                    p.getIdCliente().setCitasList(null);
                }
                if (p.getIdEmpleado() != null) {
                    em.detach(p.getIdEmpleado());
                    p.getIdEmpleado().setPedidosList(null);
                }
                p.setPagosList(null);
            }
            return lista;
        } catch(Exception e) { return new ArrayList<>(); }
        finally { if(em!=null) em.close(); }
    }

    @Override
    public List<Pedidos> listarTodosPedidos() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            List<Pedidos> lista = em.createQuery("SELECT p FROM Pedidos p ORDER BY p.idPedido DESC", Pedidos.class).getResultList();
            for (Pedidos p : lista) {
                em.detach(p);
                if (p.getDetallePedidoList() != null) {
                    List<DetallePedido> detalles = new ArrayList<>(p.getDetallePedidoList());
                    p.setDetallePedidoList(detalles);
                    for (DetallePedido dp : detalles) {
                        em.detach(dp);
                        dp.setIdPedido(null);
                        if (dp.getIdProducto() != null) {
                            em.detach(dp.getIdProducto());
                            dp.getIdProducto().setDetallePedidoList(null);
                        }
                        if (dp.getIdServicio() != null) {
                            em.detach(dp.getIdServicio());
                            dp.getIdServicio().setDetallePedidoList(null);
                        }
                    }
                }
                if (p.getIdCliente() != null) {
                    em.detach(p.getIdCliente());
                    p.getIdCliente().setPedidosList(null);
                    p.getIdCliente().setCitasList(null);
                }
                if (p.getIdEmpleado() != null) {
                    em.detach(p.getIdEmpleado());
                    p.getIdEmpleado().setPedidosList(null);
                }
                p.setPagosList(null);
            }
            return lista;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean registrarPago(entidades.Pagos pago) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(pago);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }
}
