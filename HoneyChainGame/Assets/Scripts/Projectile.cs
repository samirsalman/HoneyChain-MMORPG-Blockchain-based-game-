using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Projectile : MonoBehaviour {

    [SerializeField] float timeBeforeProjectileSelfDestruction=4f;

    private void Awake()
    {
        SetCorrectRotation();
        Destroy(gameObject, timeBeforeProjectileSelfDestruction);
    }

    private void SetCorrectRotation()
    {
        if (FindObjectOfType<Player>().transform.localScale.x > 0)
        {
            transform.rotation = transform.rotation * Quaternion.Euler(0, 0, -90);
        }
        else
        {

        }
        {
            transform.rotation = transform.rotation * Quaternion.Euler(0, 0, 90);

        }
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        Destroy(gameObject);
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        Destroy(gameObject);
            }

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        //transform.GetComponent<Rigidbody2D>().AddForce(Vector3.forward * 1000f);

;	}

    private void OnDestroy()
    {
    }
}
