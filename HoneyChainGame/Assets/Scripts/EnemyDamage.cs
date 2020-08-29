using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDamage : MonoBehaviour {

    private int currentLifes = 3;

    private void OnTriggerEnter2D(Collider2D collision)
    {
        GameObject otherCollider = collision.gameObject;
        if (otherCollider.GetComponent<Projectile>() != null)
        {
            HitProcess();
        }
    }

    private void HitProcess()
    {
        switch (currentLifes)
        {
            
            case 3:
                gameObject.GetComponent<SpriteRenderer>().color = Color.yellow;
                break;
            case 2:
                gameObject.GetComponent<SpriteRenderer>().color = Color.red;
                break;
            case 1:
                Destroy(gameObject);
                break;
            default:
                break;
        }
        currentLifes -= 1;
    }

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
